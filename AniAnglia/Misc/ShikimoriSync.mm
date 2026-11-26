//
//  ShikimoriSync.mm
//  AniLot
//
//  Синхронизация списков и прогресса просмотра с Shikimori (импорт и экспорт).
//

#import "ShikimoriSync.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "LibanixartApi.h"
#import "PlayerViewController.h"
#import "StringCvt.h"
#include <exception>
#include <vector>
#include <utility>

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

NSString* const AniLotShikimoriDidChangeNotification = @"AniLotShikimoriDidChange";

static NSString* const kShikiBase = @"https://shikimori.one";
static NSString* const kCallbackScheme = @"anilot";
static NSString* const kRedirectURI = @"anilot://shikimori";

static NSString* const kClientIDKey = @"anilot_shiki_client_id";
static NSString* const kClientSecretKey = @"anilot_shiki_client_secret";
static NSString* const kAccessTokenKey = @"anilot_shiki_access_token";
static NSString* const kRefreshTokenKey = @"anilot_shiki_refresh_token";
static NSString* const kExpiresAtKey = @"anilot_shiki_expires_at";
static NSString* const kUserIDKey = @"anilot_shiki_user_id";
static NSString* const kNicknameKey = @"anilot_shiki_nickname";
static NSString* const kSyncProgressKey = @"anilot_shiki_sync_progress";
static NSString* const kLastImportNicknameKey = @"anilot_shiki_last_import_nick";
static NSString* const kLastSyncKey = @"anilot_shiki_last_sync";
static NSString* const kReleaseMapKey = @"anilot_shiki_release_map_v1"; // MAL ID → ID релиза Anixart

static const NSTimeInterval kMinRequestInterval = 0.7; // лимит Shikimori: 5 rps и 90 rpm

#pragma mark - Помощники

static NSString* StringValue(id value) {
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

static long long LongValue(id value) {
    return [value respondsToSelector:@selector(longLongValue)] ? [value longLongValue] : 0;
}

static NSString* FormEncode(NSString* value) {
    NSMutableCharacterSet* allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:@"-._~"];
    return [value stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @"";
}

static NSString* NormalizeForMatch(NSString* title) {
    NSMutableString* result = [NSMutableString new];
    NSCharacterSet* alnum = [NSCharacterSet alphanumericCharacterSet];
    NSString* lower = title.lowercaseString;
    for (NSUInteger i = 0; i < lower.length; i++) {
        unichar c = [lower characterAtIndex:i];
        if ([alnum characterIsMember:c]) {
            [result appendFormat:@"%C", c];
        }
    }
    return result;
}

static NSArray<NSString*>* NormalizedReleaseTitles(const anixart::Release& release) {
    NSMutableArray<NSString*>* titles = [NSMutableArray new];
    NSString* original = TO_NSSTRING(release.title_original);
    NSString* russian = TO_NSSTRING(release.title_ru);
    NSString* alt = TO_NSSTRING(release.title_alt);
    if (original.length) [titles addObject:original];
    if (russian.length) [titles addObject:russian];
    if (alt.length) {
        [titles addObject:alt];
        NSCharacterSet* separators = [NSCharacterSet characterSetWithCharactersInString:@";/|"];
        for (NSString* part in [alt componentsSeparatedByCharactersInSet:separators]) {
            if (part.length) [titles addObject:part];
        }
    }
    NSMutableArray<NSString*>* result = [NSMutableArray new];
    for (NSString* title in titles) {
        NSString* normalized = NormalizeForMatch(title);
        if (normalized.length) [result addObject:normalized];
    }
    return result;
}

/* Оценка соответствия релиза Anixart записи Shikimori. Принимаем результат от 90. */
static NSInteger ScoreRelease(const anixart::Release& release, NSArray<NSString*>* wanted, NSInteger year, NSInteger episodes) {
    BOOL exact = NO;
    BOOL contains = NO;
    for (NSString* candidate in NormalizedReleaseTitles(release)) {
        for (NSString* want in wanted) {
            if ([candidate isEqualToString:want]) {
                exact = YES;
            } else if (candidate.length >= 6 && want.length >= 6 && ([candidate containsString:want] || [want containsString:candidate])) {
                contains = YES;
            }
        }
    }
    NSInteger score = exact ? 100 : (contains ? 40 : 0);
    if (score == 0) {
        return 0;
    }
    NSInteger release_year = TO_NSSTRING(release.year).integerValue;
    if (year > 0 && release_year > 0) {
        score += (year == release_year) ? 30 : -60;
    }
    if (episodes > 0 && release.episodes_total > 0) {
        score += ((NSInteger)release.episodes_total == episodes) ? 20 : -10;
    }
    return score;
}

/* Первое число из названия серии: «5 серия» → 5. 0 — не удалось определить. */
static NSInteger EpisodeNumberFromName(NSString* name) {
    if (name.length == 0) {
        return 0;
    }
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)" options:0 error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:name options:0 range:NSMakeRange(0, name.length)];
    return match ? [[name substringWithRange:[match rangeAtIndex:1]] integerValue] : 0;
}

/* Статусы Shikimori ↔ списки Anixart (значения Profile::ListStatus) */
static NSInteger AnixartStatusFromShikimori(NSString* status) {
    if ([status isEqualToString:@"planned"]) return 2;
    if ([status isEqualToString:@"watching"] || [status isEqualToString:@"rewatching"]) return 1;
    if ([status isEqualToString:@"completed"]) return 3;
    if ([status isEqualToString:@"on_hold"]) return 4;
    if ([status isEqualToString:@"dropped"]) return 5;
    return 0;
}

static NSString* ShikimoriStatusFromAnixart(NSInteger status) {
    switch (status) {
        case 1: return @"watching";
        case 2: return @"planned";
        case 3: return @"completed";
        case 4: return @"on_hold";
        case 5: return @"dropped";
        default: return nil;
    }
}

#pragma mark - Отчёт

@implementation ShikimoriSyncReport

-(NSString*)summary {
    if (_fatal_error.length) {
        return _fatal_error;
    }
    NSMutableString* text = [NSMutableString new];
    if (_cancelled) {
        [text appendString:L(@"app.shikimori.report.cancelled", @"Синхронизация остановлена.\n\n")];
    }
    [text appendFormat:L(@"app.shikimori.report.total", @"Обработано записей: %ld\n"), (long)_total];
    [text appendFormat:L(@"app.shikimori.report.synced", @"Перенесено: %ld\n"), (long)_synced];
    [text appendFormat:L(@"app.shikimori.report.progress", @"Прогресс просмотра обновлён: %ld\n"), (long)_progress_synced];
    [text appendFormat:L(@"app.shikimori.report.failed", @"Не удалось перенести: %ld"), (long)_failed];
    if (_problems.count) {
        [text appendString:L(@"app.shikimori.report.problems", @"\n\nНе найдено соответствие или произошла ошибка:\n")];
        [text appendString:[_problems componentsJoinedByString:@"\n"]];
        if (_failed > (NSInteger)_problems.count) {
            [text appendFormat:@"\n… +%ld", (long)(_failed - (NSInteger)_problems.count)];
        }
    }
    return text;
}

@end

#pragma mark - ShikimoriSync

@interface ShikimoriSync () <ASWebAuthenticationPresentationContextProviding> {
    dispatch_queue_t _queue;
    NSLock* _throttle_lock;
    NSTimeInterval _last_request_time;
    volatile BOOL _cancelled;
    volatile BOOL _running;
}
@property(nonatomic, strong) ASWebAuthenticationSession* auth_session;
@property(nonatomic, weak) UIViewController* presenting_controller;
@end

@implementation ShikimoriSync

+(instancetype)sharedInstance {
    static ShikimoriSync* instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [ShikimoriSync new];
    });
    return instance;
}

-(instancetype)init {
    self = [super init];
    _queue = dispatch_queue_create("ru.anilot.shikimori-sync", DISPATCH_QUEUE_SERIAL);
    _throttle_lock = [NSLock new];
    return self;
}

#pragma mark Настройки

-(NSString*)client_id {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kClientIDKey] ?: @"";
}
-(void)setClient_id:(NSString*)client_id {
    [[NSUserDefaults standardUserDefaults] setObject:[client_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"" forKey:kClientIDKey];
}
-(NSString*)client_secret {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kClientSecretKey] ?: @"";
}
-(void)setClient_secret:(NSString*)client_secret {
    [[NSUserDefaults standardUserDefaults] setObject:[client_secret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"" forKey:kClientSecretKey];
}
-(NSString*)redirect_uri {
    return kRedirectURI;
}
-(NSString*)nickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNicknameKey];
}
-(NSString*)accessToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenKey];
}
-(BOOL)isAuthorized {
    return [self accessToken].length > 0 && self.nickname.length > 0 && LongValue([[NSUserDefaults standardUserDefaults] objectForKey:kUserIDKey]) > 0;
}
-(BOOL)isRunning {
    return _running;
}
-(BOOL)sync_progress {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:kSyncProgressKey];
    return value ? [value boolValue] : YES;
}
-(void)setSync_progress:(BOOL)sync_progress {
    [[NSUserDefaults standardUserDefaults] setBool:sync_progress forKey:kSyncProgressKey];
}
-(NSString*)last_import_nickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLastImportNicknameKey];
}
-(void)setLast_import_nickname:(NSString*)last_import_nickname {
    [[NSUserDefaults standardUserDefaults] setObject:last_import_nickname forKey:kLastImportNicknameKey];
}
-(NSString*)last_sync_text {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncKey];
}

-(void)notifyChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AniLotShikimoriDidChangeNotification object:nil];
    });
}

-(void)cancel {
    _cancelled = YES;
}

#pragma mark Сеть

-(void)throttle {
    [_throttle_lock lock];
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval wait = _last_request_time + kMinRequestInterval - now;
    if (wait > 0) {
        [NSThread sleepForTimeInterval:wait];
    }
    _last_request_time = [NSDate timeIntervalSinceReferenceDate];
    [_throttle_lock unlock];
}

-(NSData*)perform:(NSURLRequest*)request status:(NSInteger*)status {
    __block NSData* body = nil;
    __block NSInteger code = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        body = data;
        code = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)));
    if (status) *status = code;
    return body;
}

/* Синхронный запрос к API Shikimori (вызывать не из главного потока). Возвращает разобранный JSON. */
-(id)requestMethod:(NSString*)method path:(NSString*)path query:(NSDictionary<NSString*, NSString*>*)query form:(NSDictionary<NSString*, NSString*>*)form json:(id)json_body authorized:(BOOL)authorized status:(NSInteger*)out_status {
    NSInteger code = 0;
    NSData* data = nil;
    for (int attempt = 0; attempt < 4; attempt++) {
        if (_cancelled) {
            code = -999;
            data = nil;
            break;
        }
        [self throttle];
        NSURLComponents* components = [NSURLComponents componentsWithString:[kShikiBase stringByAppendingString:path]];
        if (query.count) {
            NSMutableArray<NSURLQueryItem*>* items = [NSMutableArray new];
            for (NSString* key in query) {
                [items addObject:[NSURLQueryItem queryItemWithName:key value:query[key]]];
            }
            components.queryItems = items;
        }
        NSURL* url = components.URL;
        if (!url) {
            code = 0;
            data = nil;
            break;
        }
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
        request.timeoutInterval = 20;
        [request setValue:@"AniLot" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        if (authorized) {
            [self ensureValidToken];
            NSString* token = [self accessToken];
            if (token.length == 0) {
                code = 401;
                data = nil;
                break;
            }
            [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
        }
        if (form) {
            NSMutableArray<NSString*>* pairs = [NSMutableArray new];
            for (NSString* key in form) {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", FormEncode(key), FormEncode(form[key])]];
            }
            request.HTTPBody = [[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        } else if (json_body) {
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:json_body options:0 error:nil];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        data = [self perform:request status:&code];
        if (code == 429) {
            [NSThread sleepForTimeInterval:2.5 * (attempt + 1)];
            continue;
        }
        if (code == 401 && authorized && attempt == 0) {
            if ([self refreshAccessToken]) {
                continue;
            }
            break;
        }
        if (code >= 500 && code < 600) {
            [NSThread sleepForTimeInterval:1.0 * (attempt + 1)];
            continue;
        }
        break;
    }
    if (out_status) *out_status = code;
    if (data.length == 0) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

#pragma mark Авторизация

-(BOOL)storeTokenResponse:(id)json {
    if (![json isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSString* access = StringValue(json[@"access_token"]);
    if (access.length == 0) {
        return NO;
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:access forKey:kAccessTokenKey];
    NSString* refresh = StringValue(json[@"refresh_token"]);
    if (refresh.length) {
        [defaults setObject:refresh forKey:kRefreshTokenKey];
    }
    double created = [json[@"created_at"] doubleValue];
    double ttl = [json[@"expires_in"] doubleValue];
    if (created <= 0) created = [NSDate date].timeIntervalSince1970;
    if (ttl <= 0) ttl = 86400;
    [defaults setDouble:created + ttl forKey:kExpiresAtKey];
    return YES;
}

-(BOOL)refreshAccessToken {
    @synchronized (self) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* refresh = [defaults stringForKey:kRefreshTokenKey];
        if (refresh.length == 0 || self.client_id.length == 0) {
            return NO;
        }
        NSInteger status = 0;
        id json = [self requestMethod:@"POST" path:@"/oauth/token" query:nil form:@{
            @"grant_type": @"refresh_token",
            @"client_id": self.client_id,
            @"client_secret": self.client_secret,
            @"refresh_token": refresh
        } json:nil authorized:NO status:&status];
        return status == 200 && [self storeTokenResponse:json];
    }
}

-(void)ensureValidToken {
    double expires = [[NSUserDefaults standardUserDefaults] doubleForKey:kExpiresAtKey];
    if (expires > 0 && [NSDate date].timeIntervalSince1970 > expires - 120) {
        [self refreshAccessToken];
    }
}

-(ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession*)session {
    UIWindow* window = _presenting_controller.view.window;
    if (!window) {
        for (UIScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow* candidate in ((UIWindowScene*)scene).windows) {
                    if (candidate.isKeyWindow) {
                        window = candidate;
                        break;
                    }
                }
            }
            if (window) break;
        }
    }
    return window ?: [UIWindow new];
}

-(void)authorizeFromViewController:(UIViewController*)controller completion:(void(^)(NSString* error))completion {
    if (self.client_id.length == 0 || self.client_secret.length == 0) {
        completion(L(@"app.shikimori.error.no_client", @"Сначала укажите Client ID и Client Secret приложения Shikimori."));
        return;
    }
    NSURLComponents* components = [NSURLComponents componentsWithString:[kShikiBase stringByAppendingString:@"/oauth/authorize"]];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:self.client_id],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:kRedirectURI],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"scope" value:@"user_rates"]
    ];
    _presenting_controller = controller;
    __weak ShikimoriSync* weak_self = self;
    ASWebAuthenticationSession* session = [[ASWebAuthenticationSession alloc] initWithURL:components.URL callbackURLScheme:kCallbackScheme completionHandler:^(NSURL* callback_url, NSError* error) {
        ShikimoriSync* strong_self = weak_self;
        if (!strong_self) {
            return;
        }
        strong_self.auth_session = nil;
        if (!callback_url) {
            if (error.code == ASWebAuthenticationSessionErrorCodeCanceledLogin) {
                completion(@"");
            } else {
                completion(error.localizedDescription ?: L(@"app.shikimori.error.auth", @"Не удалось войти в Shikimori."));
            }
            return;
        }
        NSString* code = nil;
        NSString* oauth_error = nil;
        for (NSURLQueryItem* item in [NSURLComponents componentsWithURL:callback_url resolvingAgainstBaseURL:NO].queryItems) {
            if ([item.name isEqualToString:@"code"]) code = item.value;
            if ([item.name isEqualToString:@"error"]) oauth_error = item.value;
        }
        if (code.length == 0) {
            completion(oauth_error.length ? oauth_error : L(@"app.shikimori.error.auth", @"Не удалось войти в Shikimori."));
            return;
        }
        dispatch_async(strong_self->_queue, ^{
            NSString* failure = [strong_self exchangeCode:code];
            [strong_self notifyChanged];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(failure);
            });
        });
    }];
    session.presentationContextProvider = self;
    session.prefersEphemeralWebBrowserSession = NO;
    _auth_session = session;
    if (![session start]) {
        _auth_session = nil;
        completion(L(@"app.shikimori.error.auth_start", @"Не удалось открыть страницу входа Shikimori."));
    }
}

/* Обмен кода на токен и получение ника. nil — успех. */
-(NSString*)exchangeCode:(NSString*)code {
    NSInteger status = 0;
    id json = [self requestMethod:@"POST" path:@"/oauth/token" query:nil form:@{
        @"grant_type": @"authorization_code",
        @"client_id": self.client_id,
        @"client_secret": self.client_secret,
        @"code": code,
        @"redirect_uri": kRedirectURI
    } json:nil authorized:NO status:&status];
    if (status != 200 || ![self storeTokenResponse:json]) {
        NSString* description = [json isKindOfClass:[NSDictionary class]] ? (StringValue(json[@"error_description"]) ?: StringValue(json[@"error"])) : nil;
        return [NSString stringWithFormat:L(@"app.shikimori.error.token", @"Shikimori не выдал токен (HTTP %ld). %@"), (long)status, description ?: @""];
    }
    id whoami = [self requestMethod:@"GET" path:@"/api/users/whoami" query:nil form:nil json:nil authorized:YES status:&status];
    if (status != 200 || ![whoami isKindOfClass:[NSDictionary class]] || LongValue(whoami[@"id"]) <= 0) {
        [self clearAccount];
        return [NSString stringWithFormat:L(@"app.shikimori.error.whoami", @"Не удалось получить данные аккаунта (HTTP %ld)."), (long)status];
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(LongValue(whoami[@"id"])) forKey:kUserIDKey];
    [defaults setObject:StringValue(whoami[@"nickname"]) ?: @"" forKey:kNicknameKey];
    return nil;
}

-(void)clearAccount {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    for (NSString* key in @[kAccessTokenKey, kRefreshTokenKey, kExpiresAtKey, kUserIDKey, kNicknameKey]) {
        [defaults removeObjectForKey:key];
    }
}

-(void)signOut {
    [self clearAccount];
    [self notifyChanged];
}

#pragma mark Запуск операций

-(void)runOperation:(void(^)(ShikimoriSyncReport* report, void (^progress)(NSString* text, double fraction)))operation progress:(void(^)(NSString*, double))progress completion:(void(^)(ShikimoriSyncReport*))completion {
    if (_running) {
        ShikimoriSyncReport* busy = [ShikimoriSyncReport new];
        busy.fatal_error = L(@"app.shikimori.error.busy", @"Синхронизация уже выполняется.");
        completion(busy);
        return;
    }
    _running = YES;
    _cancelled = NO;
    [self notifyChanged];
    void (^report_progress)(NSString*, double) = ^(NSString* text, double fraction) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(text, fraction);
        });
    };
    dispatch_async(_queue, ^{
        ShikimoriSyncReport* report = [ShikimoriSyncReport new];
        try {
            operation(report, report_progress);
        } catch (const std::exception& e) {
            report.fatal_error = [NSString stringWithUTF8String:e.what()] ?: L(@"app.shikimori.error.unknown", @"Неизвестная ошибка синхронизации.");
        } catch (...) {
            report.fatal_error = L(@"app.shikimori.error.unknown", @"Неизвестная ошибка синхронизации.");
        }
        report.cancelled = self->_cancelled;
        self->_running = NO;
        if (!report.fatal_error.length && !report.cancelled) {
            NSDateFormatter* formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:L(@"app.shikimori.last_sync", @"%@ · перенесено %ld"), [formatter stringFromDate:[NSDate date]], (long)report.synced] forKey:kLastSyncKey];
        }
        [self notifyChanged];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(report);
        });
    });
}

-(void)addProblem:(NSString*)title toReport:(ShikimoriSyncReport*)report {
    report.failed += 1;
    if (report.problems.count < 30 && title.length) {
        report.problems = [(report.problems ?: @[]) arrayByAddingObject:title];
    }
}

#pragma mark Импорт: Shikimori → Anixart

-(void)importListsForNickname:(NSString*)nickname progress:(void(^)(NSString* text, double fraction))progress completion:(void(^)(ShikimoriSyncReport* report))completion {
    NSString* nick = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __weak ShikimoriSync* weak_self = self;
    [self runOperation:^(ShikimoriSyncReport* report, void (^report_progress)(NSString*, double)) {
        ShikimoriSync* strong_self = weak_self;
        if (strong_self) {
            [strong_self performImportForNickname:nick report:report progress:report_progress];
        }
    } progress:progress completion:completion];
}

-(void)performImportForNickname:(NSString*)nick report:(ShikimoriSyncReport*)report progress:(void (^)(NSString*, double))progress {
    if (nick.length == 0) {
        report.fatal_error = L(@"app.shikimori.error.no_nick", @"Укажите ник на Shikimori.");
        return;
    }
    BOOL own_list = self.isAuthorized && [nick caseInsensitiveCompare:self.nickname] == NSOrderedSame;
    progress(L(@"app.shikimori.progress.loading", @"Загрузка списков из Shikimori…"), 0);

    NSString* encoded_nick = [nick stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSInteger status = 0;
    id user = [self requestMethod:@"GET" path:[@"/api/users/" stringByAppendingString:encoded_nick] query:@{@"is_nickname": @"1"} form:nil json:nil authorized:own_list status:&status];
    if (_cancelled) return;
    if (status == 404 || ![user isKindOfClass:[NSDictionary class]] || LongValue(user[@"id"]) <= 0) {
        report.fatal_error = status == 404
            ? [NSString stringWithFormat:L(@"app.shikimori.error.user_not_found", @"Пользователь «%@» не найден на Shikimori."), nick]
            : [NSString stringWithFormat:L(@"app.shikimori.error.http", @"Shikimori недоступен (HTTP %ld)."), (long)status];
        return;
    }
    long long user_id = LongValue(user[@"id"]);

    NSMutableArray<NSDictionary*>* rates = [NSMutableArray new];
    NSMutableSet<NSNumber*>* seen = [NSMutableSet new];
    const NSInteger page_size = 1000;
    for (NSInteger page = 1; page <= 10; page++) {
        id chunk = [self requestMethod:@"GET" path:[NSString stringWithFormat:@"/api/users/%lld/anime_rates", user_id] query:@{
            @"limit": [NSString stringWithFormat:@"%ld", (long)page_size],
            @"page": [NSString stringWithFormat:@"%ld", (long)page],
            @"censored": @"false"
        } form:nil json:nil authorized:own_list status:&status];
        if (_cancelled) return;
        if (status != 200 || ![chunk isKindOfClass:[NSArray class]]) {
            if (page == 1) {
                report.fatal_error = [NSString stringWithFormat:L(@"app.shikimori.error.list", @"Не удалось получить список (HTTP %ld). Возможно, список скрыт настройками приватности."), (long)status];
                return;
            }
            break;
        }
        for (NSDictionary* rate in (NSArray*)chunk) {
            if (![rate isKindOfClass:[NSDictionary class]] || ![rate[@"anime"] isKindOfClass:[NSDictionary class]]) continue;
            NSNumber* anime_id = @(LongValue(rate[@"anime"][@"id"]));
            if (anime_id.longLongValue <= 0 || [seen containsObject:anime_id]) continue;
            [seen addObject:anime_id];
            [rates addObject:rate];
        }
        if ((NSInteger)((NSArray*)chunk).count < page_size) break;
    }

    report.total = (NSInteger)rates.count;
    BOOL with_progress = self.sync_progress;
    LibanixartApi* proxy = [LibanixartApi sharedInstance];
    NSUInteger item_index = 0;
    for (NSDictionary* rate in rates) {
        if (_cancelled) return;
        @autoreleasepool {
            NSDictionary* anime = rate[@"anime"];
            NSString* title = StringValue(anime[@"russian"]).length ? StringValue(anime[@"russian"]) : (StringValue(anime[@"name"]) ?: @"?");
            progress([NSString stringWithFormat:@"%lu/%lu · %@", (unsigned long)(item_index + 1), (unsigned long)rates.count, title], (double)item_index / MAX((double)rates.count, 1.0));
            item_index++;

            NSInteger list_status = AnixartStatusFromShikimori(StringValue(rate[@"status"]));
            if (list_status == 0) {
                [self addProblem:title toReport:report];
                continue;
            }
            long long release_id = [self releaseIDForAnime:anime api:proxy.api];
            if (release_id <= 0) {
                [self addProblem:title toReport:report];
                continue;
            }
            BOOL ok = NO;
            NSInteger marked = 0;
            try {
                anixart::ReleaseID rid{release_id};
                proxy.api->releases().add_release_to_profile_list(rid, static_cast<anixart::Profile::ListStatus>(list_status));
                ok = YES;
                NSInteger watched = (NSInteger)LongValue(rate[@"episodes"]);
                NSInteger total = (NSInteger)LongValue(anime[@"episodes"]);
                if (with_progress && (watched > 0 || list_status == 3)) {
                    marked = [self applyProgressWatched:watched total:total completed:(list_status == 3) releaseID:release_id api:proxy.api];
                }
            } catch (const std::exception& e) {
                NSLog(@"[AniLot Shikimori] import error for %@: %s", title, e.what());
            } catch (...) {
                NSLog(@"[AniLot Shikimori] import unknown error for %@", title);
            }
            if (ok) {
                report.synced += 1;
                if (marked > 0) report.progress_synced += 1;
            } else {
                [self addProblem:title toReport:report];
            }
        }
    }
    progress(L(@"app.shikimori.progress.done", @"Готово"), 1);
}

/* Релиз Anixart для записи Shikimori: из кэша или поиском по названию. 0 — не найден. */
-(long long)releaseIDForAnime:(NSDictionary*)anime api:(anixart::Api*)api {
    long long mal_id = LongValue(anime[@"id"]);
    NSString* key = [NSString stringWithFormat:@"%lld", mal_id];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    long long cached = LongValue([defaults dictionaryForKey:kReleaseMapKey][key]);
    if (cached > 0) {
        return cached;
    }
    long long known = AniLotKnownReleaseIDForMalID(mal_id);
    if (known > 0) {
        return known;
    }

    NSString* name = StringValue(anime[@"name"]);
    NSString* russian = StringValue(anime[@"russian"]);
    NSMutableArray<NSString*>* wanted = [NSMutableArray new];
    for (NSString* title in @[name ?: @"", russian ?: @""]) {
        NSString* normalized = NormalizeForMatch(title);
        if (normalized.length) [wanted addObject:normalized];
    }
    if (wanted.count == 0) {
        return 0;
    }
    NSString* aired = StringValue(anime[@"aired_on"]);
    NSInteger year = aired.length >= 4 ? [aired substringToIndex:4].integerValue : 0;
    NSInteger episodes = (NSInteger)LongValue(anime[@"episodes"]);

    long long best_id = 0;
    NSInteger best_score = 0;
    NSMutableArray<NSString*>* queries = [NSMutableArray new];
    if (name.length) [queries addObject:name];
    if (russian.length && ![russian isEqualToString:name]) [queries addObject:russian];
    for (NSString* query in queries) {
        try {
            anixart::requests::SearchRequest request;
            request.query = TO_STDSTRING(query);
            auto pages = api->search().release_search(request, 0);
            auto results = pages->get();
            for (const auto& release : results) {
                if (!release) continue;
                NSInteger score = ScoreRelease(*release, wanted, year, episodes);
                if (score > best_score) {
                    best_score = score;
                    best_id = static_cast<long long>(static_cast<int64_t>(release->id));
                }
            }
        } catch (const std::exception& e) {
            NSLog(@"[AniLot Shikimori] search error for %@: %s", query, e.what());
        } catch (...) {
        }
        if (best_score >= 120) break;
        [NSThread sleepForTimeInterval:0.15];
    }
    if (best_score >= 90 && best_id > 0) {
        NSMutableDictionary* map = [[defaults dictionaryForKey:kReleaseMapKey] mutableCopy] ?: [NSMutableDictionary new];
        map[key] = @(best_id);
        [defaults setObject:map forKey:kReleaseMapKey];
        return best_id;
    }
    return 0;
}

/* Отмечает серии просмотренными в Anixart. Возвращает число отмеченных серий. */
-(NSInteger)applyProgressWatched:(NSInteger)watched total:(NSInteger)total completed:(BOOL)completed releaseID:(long long)release_value api:(anixart::Api*)api {
    anixart::ReleaseID release_id{release_value};
    auto types = api->episodes().get_release_types(release_id);
    if (types.empty()) {
        return 0;
    }
    anixart::EpisodeType::Ptr type = types[0];
    for (const auto& candidate : types) {
        if (candidate && type && candidate->episodes_count > type->episodes_count) {
            type = candidate;
        }
    }
    if (!type) {
        return 0;
    }
    auto sources = api->episodes().get_release_sources(release_id, type->id);
    if (sources.empty()) {
        return 0;
    }
    anixart::EpisodeSource::Ptr source = sources[0];
    for (const auto& candidate : sources) {
        if (candidate && source && candidate->episodes_count > source->episodes_count) {
            source = candidate;
        }
    }
    if (!source) {
        return 0;
    }
    if (completed && (watched <= 0 || (total > 0 && watched >= total))) {
        api->episodes().add_watched(release_id, source->id);
        return MAX(total, (NSInteger)1);
    }
    auto episodes = api->episodes().get_release_episodes(release_id, type->id, source->id, anixart::Episode::Sort::FromLeast);
    NSInteger limit = MIN(watched, (NSInteger)episodes.size());
    NSInteger marked = 0;
    for (NSInteger i = 0; i < limit; i++) {
        if (_cancelled) break;
        const auto& episode = episodes[(size_t)i];
        if (!episode || episode->is_watched) continue;
        api->episodes().add_watched_episode(release_id, source->id, episode->position);
        marked++;
        [NSThread sleepForTimeInterval:0.05];
    }
    return marked;
}

#pragma mark Экспорт: Anixart → Shikimori

-(void)exportListsWithProgress:(void(^)(NSString* text, double fraction))progress completion:(void(^)(ShikimoriSyncReport* report))completion {
    __weak ShikimoriSync* weak_self = self;
    [self runOperation:^(ShikimoriSyncReport* report, void (^report_progress)(NSString*, double)) {
        ShikimoriSync* strong_self = weak_self;
        if (strong_self) {
            [strong_self performExportWithReport:report progress:report_progress];
        }
    } progress:progress completion:completion];
}

-(void)performExportWithReport:(ShikimoriSyncReport*)report progress:(void (^)(NSString*, double))progress {
    if (!self.isAuthorized) {
        report.fatal_error = L(@"app.shikimori.error.not_authorized", @"Для экспорта войдите в аккаунт Shikimori.");
        return;
    }
    long long user_id = LongValue([[NSUserDefaults standardUserDefaults] objectForKey:kUserIDKey]);
    LibanixartApi* proxy = [LibanixartApi sharedInstance];
    BOOL with_progress = self.sync_progress;

    // 1) читаем списки Anixart
    std::vector<std::pair<anixart::Release::Ptr, NSInteger>> items;
    const NSInteger statuses[] = {1, 2, 3, 4, 5};
    for (NSInteger status : statuses) {
        if (_cancelled) return;
        progress([NSString stringWithFormat:L(@"app.shikimori.progress.reading", @"Чтение списков Anixart… (%ld/5)"), (long)status], 0);
        try {
            auto pages = proxy.api->releases().my_profile_list(static_cast<anixart::Profile::ListStatus>(status), anixart::Profile::ListSort::Descending, 0);
            auto chunk = pages->get();
            for (const auto& release : chunk) {
                if (release) items.push_back({release, status});
            }
            int guard = 0;
            while (!pages->is_end() && guard++ < 200 && !_cancelled) {
                chunk = pages->next();
                if (chunk.empty()) break;
                for (const auto& release : chunk) {
                    if (release) items.push_back({release, status});
                }
            }
        } catch (const std::exception& e) {
            report.fatal_error = [NSString stringWithFormat:L(@"app.shikimori.error.anixart_list", @"Не удалось прочитать списки Anixart: %s"), e.what()];
            return;
        } catch (...) {
            report.fatal_error = L(@"app.shikimori.error.anixart_list_unknown", @"Не удалось прочитать списки Anixart.");
            return;
        }
    }
    report.total = (NSInteger)items.size();

    // 2) отправляем в Shikimori
    NSUInteger item_index = 0;
    for (const auto& entry : items) {
        if (_cancelled) return;
        @autoreleasepool {
            anixart::Release::Ptr release = entry.first;
            NSInteger list_status = entry.second;
            NSString* title = TO_NSSTRING(release->title_ru);
            if (title.length == 0) title = TO_NSSTRING(release->title_original);
            if (title.length == 0) title = [NSString stringWithFormat:@"#%lld", (long long)static_cast<int64_t>(release->id)];
            progress([NSString stringWithFormat:@"%lu/%lu · %@", (unsigned long)(item_index + 1), (unsigned long)items.size(), title], (double)item_index / MAX((double)items.size(), 1.0));
            item_index++;

            long long release_value = static_cast<long long>(static_cast<int64_t>(release->id));
            NSString* original = TO_NSSTRING(release->title_original);
            NSInteger year = TO_NSSTRING(release->year).integerValue;
            NSInteger total_episodes = (NSInteger)release->episodes_total;

            NSTimeInterval started = [NSDate timeIntervalSinceReferenceDate];
            NSString* mal_id = AniLotLookupMalID(release_value, original.length ? original : title, year, total_episodes);
            if ([NSDate timeIntervalSinceReferenceDate] - started > 0.05) {
                [NSThread sleepForTimeInterval:kMinRequestInterval]; // был сетевой поиск — выдерживаем лимит Shikimori
            }
            long long mal = mal_id.longLongValue;
            if (mal <= 0) {
                [self addProblem:title toReport:report];
                continue;
            }

            // сколько серий просмотрено
            NSInteger watched = 0;
            if (list_status == 3) {
                watched = total_episodes;
            } else if (with_progress && (list_status == 1 || list_status == 4 || list_status == 5)) {
                watched = [self watchedEpisodesForRelease:release api:proxy.api];
                if (total_episodes > 0) watched = MIN(watched, total_episodes);
            }

            NSString* shiki_status = ShikimoriStatusFromAnixart(list_status);
            NSMutableDictionary* user_rate = [@{
                @"user_id": @(user_id),
                @"target_id": @(mal),
                @"target_type": @"Anime",
                @"status": shiki_status
            } mutableCopy];
            if (watched > 0) {
                user_rate[@"episodes"] = @(watched);
            }
            if ([self pushUserRate:user_rate userID:user_id targetID:mal]) {
                report.synced += 1;
                if (watched > 0) report.progress_synced += 1;
            } else {
                [self addProblem:title toReport:report];
            }
        }
    }
    progress(L(@"app.shikimori.progress.done", @"Готово"), 1);
}

/* Номер последней просмотренной серии релиза. 0 — неизвестно. */
-(NSInteger)watchedEpisodesForRelease:(anixart::Release::Ptr)release api:(anixart::Api*)api {
    try {
        anixart::Episode::Ptr last = release->last_view_episode;
        if (!last) {
            auto full = api->releases().get_release(release->id);
            if (full) last = full->last_view_episode;
        }
        if (last) {
            return EpisodeNumberFromName(TO_NSSTRING(last->name));
        }
    } catch (const std::exception& e) {
        NSLog(@"[AniLot Shikimori] progress read error: %s", e.what());
    } catch (...) {
    }
    return 0;
}

/* Создаёт запись списка в Shikimori или обновляет существующую */
-(BOOL)pushUserRate:(NSDictionary*)user_rate userID:(long long)user_id targetID:(long long)target_id {
    NSInteger status = 0;
    [self requestMethod:@"POST" path:@"/api/v2/user_rates" query:nil form:nil json:@{@"user_rate": user_rate} authorized:YES status:&status];
    if (status == 200 || status == 201) {
        return YES;
    }
    if (status != 422 && status != 409) {
        return NO;
    }
    // запись уже существует — находим и обновляем
    id existing = [self requestMethod:@"GET" path:@"/api/v2/user_rates" query:@{
        @"user_id": [NSString stringWithFormat:@"%lld", user_id],
        @"target_id": [NSString stringWithFormat:@"%lld", target_id],
        @"target_type": @"Anime"
    } form:nil json:nil authorized:YES status:&status];
    NSDictionary* first = ([existing isKindOfClass:[NSArray class]] && [(NSArray*)existing count] > 0) ? [(NSArray*)existing firstObject] : nil;
    long long rate_id = [first isKindOfClass:[NSDictionary class]] ? LongValue(first[@"id"]) : 0;
    if (rate_id <= 0) {
        return NO;
    }
    NSMutableDictionary* patch = [NSMutableDictionary new];
    patch[@"status"] = user_rate[@"status"];
    if (user_rate[@"episodes"]) patch[@"episodes"] = user_rate[@"episodes"];
    [self requestMethod:@"PATCH" path:[NSString stringWithFormat:@"/api/v2/user_rates/%lld", rate_id] query:nil form:nil json:@{@"user_rate": patch} authorized:YES status:&status];
    return status == 200 || status == 201;
}

@end
