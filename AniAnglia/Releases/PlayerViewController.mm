//
//  PlayerViewController.mm
//  AniLot
//
//  Собственный плеер приложения и менеджер загрузок серий.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#include <chrono>
#include <climits>
#include <cstdlib>
#import "PlayerViewController.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "AniLotSubtitles.h"

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

NSString* const DownloadManagerDidUpdateNotification = @"AniLotDownloadManagerDidUpdate";
NSString* const AniLotEpisodeWatchedNotification = @"AniLotEpisodeWatched";

NSString* const AniLotSettingResumeKey = @"anilot_resume_enabled";
NSString* const AniLotSettingSkipButtonsKey = @"anilot_skip_buttons";
NSString* const AniLotSettingAutoSkipKey = @"anilot_auto_skip";
static NSString* const kExternalPlayerKey = @"anilot_external_player";
static NSString* const kPositionsKey = @"anilot_positions";
static NSString* const kSubtitleLabelKey = @"anilot_subtitle_label"; // последняя выбранная дорожка субтитров («» — выключены)

BOOL AniLotSettingBool(NSString* key, BOOL default_value) {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value ? [value boolValue] : default_value;
}

void AniLotSetSettingBool(NSString* key, BOOL value) {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
}

NSArray<NSString*>* AniLotExternalPlayerIDs(void) {
    return @[@"internal", @"vlc", @"outplayer", @"nplayer", @"share"];
}

NSString* AniLotExternalPlayerName(NSString* identifier) {
    NSDictionary<NSString*, NSString*>* names = @{
        @"internal": L(@"app.player.external.internal", @"Встроенный"),
        @"vlc": @"VLC",
        @"outplayer": @"OutPlayer",
        @"nplayer": @"nPlayer",
        @"share": L(@"app.player.external.share", @"Поделиться ссылкой…")
    };
    return names[identifier] ?: identifier;
}

NSString* AniLotExternalPlayerID(void) {
    NSString* value = [[NSUserDefaults standardUserDefaults] stringForKey:kExternalPlayerKey];
    return (value && [AniLotExternalPlayerIDs() containsObject:value]) ? value : @"internal";
}

void AniLotSetExternalPlayerID(NSString* identifier) {
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kExternalPlayerKey];
}

static double SavedPosition(NSString* key) {
    NSDictionary* positions = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPositionsKey];
    return [positions[key] doubleValue];
}

static void SavePosition(NSString* key, double seconds) {
    NSMutableDictionary* positions = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kPositionsKey] mutableCopy] ?: [NSMutableDictionary new];
    positions[key] = @(seconds);
    [[NSUserDefaults standardUserDefaults] setObject:positions forKey:kPositionsKey];
}

static void ClearPosition(NSString* key) {
    NSMutableDictionary* positions = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kPositionsKey] mutableCopy];
    if (positions[key]) {
        [positions removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:positions forKey:kPositionsKey];
    }
}

#pragma mark - Помощники

static NSArray<NSString*>* SortedQualityNames(NSDictionary<NSString*, NSURL*>* urls) {
    return [urls.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a, NSString* b) {
        return [@(a.integerValue) compare:@(b.integerValue)];
    }];
}

static NSString* ChooseQualityName(NSDictionary<NSString*, NSURL*>* urls, NSString* preferred) {
    if (preferred.length && urls[preferred]) {
        return preferred;
    }
    return SortedQualityNames(urls).lastObject;
}

static NSString* QualityTitle(NSString* name) {
    return name.integerValue > 0 ? [name stringByAppendingString:@"p"] : name;
}

static NSString* FormatTime(double seconds) {
    if (!isfinite(seconds) || seconds < 0) {
        seconds = 0;
    }
    long total = (long)seconds;
    long h = total / 3600, m = (total % 3600) / 60, s = total % 60;
    if (h > 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", h, m, s];
    }
    return [NSString stringWithFormat:@"%ld:%02ld", m, s];
}

static UIViewController* TopViewController(void) {
    UIWindow* window = nil;
    for (UIScene* scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        for (UIWindow* w in ((UIWindowScene*)scene).windows) {
            if (w.isKeyWindow) {
                window = w;
            }
        }
        if (window) {
            break;
        }
    }
    if (!window) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    UIViewController* controller = window.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    return controller;
}

#pragma mark - AniLibria / AniLiberty (новый API v1)

/* Парсер Libria внутри libanixart ходит на api.anilibria.tv/v2, который отключён (HTTP 410).
   Поэтому ссылки на потоки Libria/Liberty получаем напрямую из нового API AniLiberty. */

static NSData* SyncRequest(NSURL* url, NSDictionary<NSString*, NSString*>* headers, NSInteger* status, NSString** error_text) {
    __block NSData* body = nil;
    __block NSInteger code = 0;
    __block NSString* err = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15;
    for (NSString* key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        body = data;
        code = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
        err = error.localizedDescription;
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC)));
    if (status) *status = code;
    if (error_text) *error_text = err;
    return body;
}

static NSData* SyncGET(NSURL* url, NSInteger* status, NSString** error_text) {
    return SyncRequest(url, @{@"Accept": @"application/json"}, status, error_text);
}

static NSString* FirstMatch(NSString* pattern, NSString* text) {
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (match && match.numberOfRanges > 1 && [match rangeAtIndex:1].location != NSNotFound) {
        return [text substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

static NSString* QualityFromKey(NSString* key) {
    NSString* lower = key.lowercaseString;
    if ([lower isEqualToString:@"fhd"]) return @"1080";
    if ([lower isEqualToString:@"hd"]) return @"720";
    if ([lower isEqualToString:@"sd"]) return @"480";
    return lower;
}

/* Источник Liberty отдаёт ссылку на iframe-страницу (anixart.libria.fun/public/iframe.php?...).
   Загружаем страницу и достаём из неё HLS-ссылки. */
static NSDictionary<NSString*, NSURL*>* ResolveIframeStreams(NSString* target, NSMutableString* detail, NSMutableArray<AniLotSubtitleTrack*>* subtitles) {
    NSURL* url = [NSURL URLWithString:target];
    if (!url) {
        return nil;
    }
    NSDictionary* headers = @{
        @"Accept": @"text/html,application/xhtml+xml,*/*",
        @"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
        @"Referer": [NSString stringWithFormat:@"%@://%@/", url.scheme, url.host]
    };
    NSInteger status = 0;
    NSString* error_text = nil;
    NSData* data = SyncRequest(url, headers, &status, &error_text);
    NSString* html = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    [detail appendFormat:@"iframe %@ → HTTP %ld %@\n", url.host, (long)status, error_text ?: @""];
    if (html.length == 0) {
        return nil;
    }
    html = [html stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    // Субтитры, которые отдаёт страница плеера (<track>, playerjs "subtitle", ссылки .vtt/.srt/.ass)
    if (subtitles) {
        NSArray<AniLotSubtitleTrack*>* found = AniLotFindSubtitleTracks(html, url);
        [subtitles addObjectsFromArray:found];
        if (found.count) {
            [detail appendFormat:@"Субтитры: найдено %lu\n", (unsigned long)found.count];
        }
    }
    
    NSMutableDictionary<NSString*, NSURL*>* streams = [NSMutableDictionary new];
    void (^add)(NSString*, NSString*) = ^(NSString* quality, NSString* link) {
        if ([link hasPrefix:@"//"]) {
            link = [@"https:" stringByAppendingString:link];
        }
        NSURL* link_url = [link hasPrefix:@"http"] ? [NSURL URLWithString:link] : nil;
        if (link_url && quality.length && !streams[quality]) {
            streams[quality] = link_url;
        }
    };
    
    // 1) [1080p]https://....m3u8
    NSRegularExpression* bracket = [NSRegularExpression regularExpressionWithPattern:@"\\[(\\d{3,4})p?\\]\\s*((?:https?:)?//[^,\\s\"'<>\\]]+)" options:0 error:nil];
    for (NSTextCheckingResult* m in [bracket matchesInString:html options:0 range:NSMakeRange(0, html.length)]) {
        add([html substringWithRange:[m rangeAtIndex:1]], [html substringWithRange:[m rangeAtIndex:2]]);
    }
    // 2) "hls_1080":"...", "fhd":"..."
    NSRegularExpression* keyed = [NSRegularExpression regularExpressionWithPattern:@"\"(?:hls_)?(1080|720|480|360|fhd|hd|sd)\"\\s*:\\s*\"((?:https?:)?//[^\"]+)\"" options:0 error:nil];
    for (NSTextCheckingResult* m in [keyed matchesInString:html options:0 range:NSMakeRange(0, html.length)]) {
        add(QualityFromKey([html substringWithRange:[m rangeAtIndex:1]]), [html substringWithRange:[m rangeAtIndex:2]]);
    }
    // 3) любые .m3u8-ссылки
    NSRegularExpression* bare = [NSRegularExpression regularExpressionWithPattern:@"((?:https?:)?//[^\"'\\s<>\\\\]+?\\.m3u8[^\"'\\s<>\\\\]*)" options:0 error:nil];
    NSUInteger index = 0;
    for (NSTextCheckingResult* m in [bare matchesInString:html options:0 range:NSMakeRange(0, html.length)]) {
        NSString* link = [html substringWithRange:[m rangeAtIndex:1]];
        NSString* quality = FirstMatch(@"(1080|720|480|360)", link);
        add(quality ?: [NSString stringWithFormat:@"auto%lu", (unsigned long)index++], link);
    }
    
    if (streams.count == 0) {
        NSString* compact = [[html componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@" "];
        [detail appendFormat:@"В странице нет HLS-ссылок (%lu байт). Начало: %@\n", (unsigned long)html.length, [compact substringToIndex:MIN((NSUInteger)500, compact.length)]];
    }
    return streams.count ? streams : nil;
}

static NSDictionary<NSString*, NSURL*>* ResolveLibriaStreams(NSString* target, NSMutableString* detail, NSMutableDictionary* markers) {
    NSString* release_key = FirstMatch(@"[?&]id=(\\d+)", target);
    if (!release_key) {
        release_key = FirstMatch(@"/release/([a-z0-9_-]+)", target);
    }
    NSString* ep_text = FirstMatch(@"[?&]ep=(\\d+)", target);
    double episode_number = ep_text ? ep_text.doubleValue : 1;
    [detail appendFormat:@"Libria: %@\n", target];
    if (!release_key) {
        [detail appendString:@"Не удалось определить релиз из ссылки\n"];
        return nil;
    }
    
    NSDictionary* release = nil;
    for (NSString* base in @[@"https://aniliberty.top/api/v1", @"https://anilibria.top/api/v1"]) {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/anime/releases/%@", base, release_key]];
        NSInteger status = 0;
        NSString* error_text = nil;
        NSData* data = SyncGET(url, &status, &error_text);
        [detail appendFormat:@"%@ → HTTP %ld %@\n", url.host, (long)status, error_text ?: @""];
        if (status == 200 && data) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                release = json;
                break;
            }
        }
    }
    NSArray* episodes = [release[@"episodes"] isKindOfClass:[NSArray class]] ? release[@"episodes"] : nil;
    if (episodes.count == 0) {
        [detail appendString:@"В ответе нет списка серий\n"];
        return nil;
    }
    
    NSDictionary* chosen = nil;
    for (NSDictionary* episode in episodes) {
        if ([episode isKindOfClass:[NSDictionary class]] && [episode[@"ordinal"] respondsToSelector:@selector(doubleValue)] && [episode[@"ordinal"] doubleValue] == episode_number) {
            chosen = episode;
            break;
        }
    }
    if (!chosen) {
        NSInteger index = (NSInteger)episode_number - 1;
        if (index >= 0 && index < (NSInteger)episodes.count && [episodes[index] isKindOfClass:[NSDictionary class]]) {
            chosen = episodes[index];
        }
    }
    if (!chosen) {
        [detail appendFormat:@"Серия %g не найдена среди %lu\n", episode_number, (unsigned long)episodes.count];
        return nil;
    }
    
    // Метки опенинга и эндинга (секунды), если источник их отдаёт
    if (markers) {
        for (NSString* name in @[@"opening", @"ending"]) {
            NSDictionary* marker = chosen[name];
            if (![marker isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            id start = marker[@"start"];
            id stop = marker[@"stop"];
            if ([start respondsToSelector:@selector(doubleValue)] && [stop respondsToSelector:@selector(doubleValue)] && [stop doubleValue] > [start doubleValue]) {
                markers[name] = @[@([start doubleValue]), @([stop doubleValue])];
            }
        }
    }
    
    NSMutableDictionary<NSString*, NSURL*>* streams = [NSMutableDictionary new];
    for (NSString* key in @[@"hls_480", @"hls_720", @"hls_1080"]) {
        NSString* link = chosen[key];
        if (![link isKindOfClass:[NSString class]] || link.length == 0) {
            continue;
        }
        if ([link hasPrefix:@"/"]) {
            link = [@"https://aniliberty.top" stringByAppendingString:link];
        }
        NSURL* url = [NSURL URLWithString:link];
        if (url) {
            streams[[key substringFromIndex:4]] = url;
        }
    }
    if (streams.count == 0) {
        [detail appendString:@"У серии нет HLS-ссылок\n"];
    }
    return streams.count ? streams : nil;
}

#pragma mark - Заголовки для потоков (Sibnet и др.)

static NSMutableDictionary<NSString*, NSDictionary<NSString*, NSString*>*>* StreamHeadersStore(void) {
    static NSMutableDictionary* store = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        store = [NSMutableDictionary new];
    });
    return store;
}

static void RememberStreamHeaders(NSURL* url, NSDictionary<NSString*, NSString*>* headers) {
    if (!url.host.length || !headers.count) {
        return;
    }
    NSMutableDictionary* store = StreamHeadersStore();
    @synchronized (store) {
        store[url.host] = headers;
    }
}

static NSDictionary<NSString*, NSString*>* HeadersForStream(NSURL* url) {
    NSMutableDictionary* store = StreamHeadersStore();
    @synchronized (store) {
        return url.host ? store[url.host] : nil;
    }
}

static NSURLRequest* RequestForStream(NSURL* url) {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary<NSString*, NSString*>* headers = HeadersForStream(url);
    for (NSString* key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

/* Определяет конечный адрес после редиректов, не скачивая тело файла.
   Важно: делегатные методы didReceiveResponse не вызываются, если у задачи есть completionHandler,
   поэтому используем задачу без него и ждём didCompleteWithError. Редиректы обрабатываем вручную —
   так мы получаем адрес CDN (Sibnet отдаёт Location вида //dvNN.sibnet.ru/...) и можем поднять http до https. */
@interface AniLotRedirectResolver : NSObject <NSURLSessionDataDelegate>
@property(nonatomic, strong) NSURL* redirect_url;
@property(nonatomic) NSInteger status;
@property(nonatomic, strong) dispatch_semaphore_t done;
@end
@implementation AniLotRedirectResolver
-(instancetype)init {
    self = [super init];
    _done = dispatch_semaphore_create(0);
    return self;
}
-(void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task willPerformHTTPRedirection:(NSHTTPURLResponse*)response newRequest:(NSURLRequest*)request completionHandler:(void (^)(NSURLRequest*))completion_handler {
    _redirect_url = request.URL;
    completion_handler(nil); // по редиректу не идём: нужен только адрес
}
-(void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask*)task didReceiveResponse:(NSURLResponse*)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completion_handler {
    _status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
    completion_handler(NSURLSessionResponseCancel);
}
-(void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task didCompleteWithError:(NSError*)error {
    dispatch_semaphore_signal(_done);
}
@end

static NSURL* SecureURL(NSURL* url) {
    if (!url) {
        return nil;
    }
    NSString* scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"https"]) {
        return url;
    }
    NSURLComponents* comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (comps.host.length == 0) {
        return url;
    }
    if (scheme.length == 0 || [scheme isEqualToString:@"http"]) {
        comps.scheme = @"https";
    }
    return comps.URL ?: url;
}

/* Один запрос без следования редиректам: статус и адрес из Location */
static NSInteger ProbeURL(NSURL* url, NSDictionary<NSString*, NSString*>* headers, NSURL** redirect) {
    AniLotRedirectResolver* resolver = [AniLotRedirectResolver new];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:resolver delegateQueue:nil];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15;
    for (NSString* key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    [request setValue:@"bytes=0-0" forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
    [task resume];
    if (dispatch_semaphore_wait(resolver.done, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC))) != 0) {
        [task cancel];
    }
    [session invalidateAndCancel];
    if (redirect) *redirect = resolver.redirect_url;
    return resolver.status;
}

static NSURL* ResolveFinalURL(NSURL* url, NSDictionary<NSString*, NSString*>* headers, NSInteger* status) {
    NSURL* current = SecureURL(url);
    NSInteger last_status = 0;
    for (int hop = 0; hop < 6 && current; hop++) {
        NSURL* redirect = nil;
        NSInteger code = ProbeURL(current, headers, &redirect);
        if (code == 0 && [current.scheme isEqualToString:@"https"] && ![url.scheme isEqualToString:@"https"] && hop == 0) {
            // https недоступен — пробуем исходный адрес как есть
            current = url;
            continue;
        }
        last_status = code;
        if (code >= 300 && code < 400 && redirect) {
            NSURL* secure = SecureURL(redirect);
            // не даём зациклиться на https -> http -> https
            if ([secure isEqual:current]) {
                break;
            }
            current = secure;
            continue;
        }
        break;
    }
    if (status) *status = last_status;
    return current;
}

#pragma mark - Sibnet

/* Парсер Sibnet внутри libanixart устарел: страница плеера теперь отдаёт путь /v/<hash>/<id>.mp4,
   который редиректит на CDN и требует Referer. Разбираем страницу сами. */
static NSDictionary<NSString*, NSURL*>* ResolveSibnetStreams(NSString* target, NSMutableString* detail, NSMutableArray<AniLotSubtitleTrack*>* subtitles) {
    [detail appendFormat:@"Sibnet: %@\n", target ?: @""];

    NSString* user_agent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1";
    NSString* shell = nil;
    NSString* absolute = nil;

    // Если Anixart уже передал прямую стабильную ссылку Sibnet — не загружаем shell.php повторно.
    NSString* direct = FirstMatch(@"((?:https?:)?//[^\"'\\s<>]+?/v/[^\"'\\s<>]+?\\.mp4(?:\\?[^\"'\\s<>]*)?)", target)
        ?: FirstMatch(@"(/v/[^\"'\\s<>]+?\\.mp4(?:\\?[^\"'\\s<>]*)?)", target);
    if (direct) {
        if ([direct hasPrefix:@"//"]) {
            absolute = [@"https:" stringByAppendingString:direct];
        } else if ([direct hasPrefix:@"/"]) {
            absolute = [@"https://video.sibnet.ru" stringByAppendingString:direct];
        } else {
            absolute = direct;
        }
        shell = @"https://video.sibnet.ru/";
    } else {
        NSString* video_id = FirstMatch(@"videoid=(\\d+)", target)
            ?: FirstMatch(@"/video(\\d+)", target)
            ?: FirstMatch(@"embed/(\\d+)", target)
            ?: FirstMatch(@"[?&]id=(\\d+)", target);
        if (!video_id) {
            [detail appendString:@"Не удалось определить videoid и в ссылке нет прямого /v/...mp4\n"];
            return nil;
        }

        shell = [NSString stringWithFormat:@"https://video.sibnet.ru/shell.php?videoid=%@", video_id];
        NSDictionary* page_headers = @{
            @"User-Agent": user_agent,
            @"Referer": @"https://video.sibnet.ru/",
            @"Accept": @"text/html,application/xhtml+xml,*/*"
        };
        NSInteger status = 0;
        NSString* error_text = nil;
        NSData* data = SyncRequest([NSURL URLWithString:shell], page_headers, &status, &error_text);
        [detail appendFormat:@"shell.php → HTTP %ld %@\n", (long)status, error_text ?: @""];

        NSString* html = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (!html) {
            html = data ? [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding] : nil;
        }
        if (html.length == 0) {
            // Повторяем без User-Agent: некоторые ответы Sibnet зависят от заголовков клиента.
            data = SyncRequest([NSURL URLWithString:shell], @{@"Referer": @"https://video.sibnet.ru/"}, &status, &error_text);
            [detail appendFormat:@"shell.php (retry) → HTTP %ld %@\n", (long)status, error_text ?: @""];
            html = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
            if (!html) {
                html = data ? [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding] : nil;
            }
        }
        if (html.length == 0) {
            [detail appendString:@"Sibnet вернул пустую страницу shell.php\n"];
            return nil;
        }

        html = [html stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        if (subtitles) {
            [subtitles addObjectsFromArray:AniLotFindSubtitleTracks(html, [NSURL URLWithString:shell])];
        }
        NSString* media = FirstMatch(@"((?:https?:)?//[^\"'\\s<>]+?\\.mp4(?:\\?[^\"'\\s<>]*)?)", html)
            ?: FirstMatch(@"(/v/[^\"'\\s<>]+?\\.mp4(?:\\?[^\"'\\s<>]*)?)", html);
        if (!media) {
            NSString* compact = [[html componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@" "];
            [detail appendFormat:@"В shell.php не найдена MP4-ссылка (%lu байт). Начало: %@\n",
                (unsigned long)html.length, [compact substringToIndex:MIN((NSUInteger)350, compact.length)]];
            return nil;
        }
        if ([media hasPrefix:@"//"]) {
            absolute = [@"https:" stringByAppendingString:media];
        } else if ([media hasPrefix:@"/"]) {
            absolute = [@"https://video.sibnet.ru" stringByAppendingString:media];
        } else {
            absolute = media;
        }
    }

    NSURL* stable_url = SecureURL([NSURL URLWithString:absolute]);
    if (!stable_url || !stable_url.host.length || ![stable_url.scheme isEqualToString:@"https"]) {
        [detail appendFormat:@"Некорректная MP4-ссылка: %@\n", absolute ?: @"(пусто)"];
        return nil;
    }

    // Важно: НЕ разворачиваем 302 здесь. CDN-URL содержит короткоживущую подпись,
    // поэтому AVPlayer должен получить стабильный /v/...mp4 и сам пройти редирект.
    NSDictionary* media_headers = @{
        @"User-Agent": user_agent,
        @"Referer": shell ?: @"https://video.sibnet.ru/"
    };
    RememberStreamHeaders(stable_url, media_headers);
    [detail appendFormat:@"Используется стабильная ссылка Sibnet: %@\n", stable_url.host];
    return @{@"720": stable_url};
}

#pragma mark - AniSkip (метки опенингов и эндингов для любых источников)

/* v4: MAL ID теперь сопоставляется через Shikimori; прежние результаты AniList/Jikan не переиспользуем. */
static NSString* const kMalIdsKey = @"anilot_mal_ids_v4";
static NSString* const kMalIdLookupDatesKey = @"anilot_mal_id_lookup_dates_v1";
static const NSTimeInterval kMalIdNotFoundTTL = 7.0 * 24.0 * 60.0 * 60.0;

static NSString* const kSkipMarkersKey = @"anilot_skip_markers_v1";
static const NSTimeInterval kSkipMarkersTTL = 14.0 * 24.0 * 60.0 * 60.0;
static const NSTimeInterval kSkipMarkersMissTTL = 24.0 * 60.0 * 60.0;
static const NSTimeInterval kSkipMarkersPruneAge = 60.0 * 24.0 * 60.0 * 60.0;

static NSData* SyncGETRetryWithHeaders(NSURL* url, int tries, NSDictionary<NSString*, NSString*>* headers, NSInteger* status) {
    NSInteger code = 0;
    for (int i = 0; i < tries; i++) {
        NSData* data = SyncRequest(url, headers, &code, nil);
        if (code == 200 && data) {
            if (status) *status = code;
            return data;
        }
        if (code == 404 || (code >= 400 && code < 500 && code != 429)) {
            break;
        }
        [NSThread sleepForTimeInterval:0.8 * (i + 1)];
    }
    if (status) *status = code;
    return nil;
}

/* Повторные GET для AniSkip: тот же User-Agent, что использует клиент Aniko. */
static NSData* SyncGETRetry(NSURL* url, int tries, NSInteger* status) {
    NSDictionary* headers = @{
        @"Accept": @"application/json",
        @"User-Agent": @"AniLot"
    };
    return SyncGETRetryWithHeaders(url, tries, headers, status);
}

static NSString* NormalizeTitle(NSString* title) {
    NSMutableString* result = [NSMutableString new];
    NSString* lower = title.lowercaseString;
    NSCharacterSet* letters = [NSCharacterSet alphanumericCharacterSet];
    for (NSUInteger i = 0; i < lower.length; i++) {
        unichar c = [lower characterAtIndex:i];
        if ([letters characterIsMember:c]) {
            [result appendFormat:@"%C", c];
        }
    }
    return result;
}

static NSInteger ShikimoriYear(NSDictionary* anime) {
    id aired_on = anime[@"aired_on"];
    if (![aired_on isKindOfClass:[NSString class]]) {
        return 0;
    }
    return [FirstMatch(@"^(\\d{4})", aired_on) integerValue];
}

static BOOL ShikimoriCandidateHasExactTitle(NSDictionary* candidate, NSString* query) {
    NSString* normalized_query = NormalizeTitle(query);
    if (normalized_query.length == 0) {
        return NO;
    }
    for (NSString* name in candidate[@"names"]) {
        if ([NormalizeTitle(name) isEqualToString:normalized_query]) {
            return YES;
        }
    }
    return NO;
}

/* Сначала точное название, затем совместимые год и число серий. Не выбираем первый похожий результат. */
static NSString* ChooseShikimoriCandidate(NSArray<NSDictionary*>* candidates, NSString* query, NSInteger year, NSInteger episodes_total) {
    NSMutableArray<NSDictionary*>* exact_matches = [NSMutableArray new];
    for (NSDictionary* candidate in candidates) {
        if (![candidate[@"id"] respondsToSelector:@selector(longLongValue)] ||
            [candidate[@"id"] longLongValue] <= 0 ||
            !ShikimoriCandidateHasExactTitle(candidate, query)) {
            continue;
        }

        NSInteger candidate_year = [candidate[@"year"] integerValue];
        NSInteger candidate_episodes = [candidate[@"episodes"] integerValue];

        if (year > 0 && candidate_year > 0 && std::labs((long)candidate_year - (long)year) > 1) {
            continue;
        }
        if (episodes_total > 0 && candidate_episodes > 0 && candidate_episodes != episodes_total) {
            continue;
        }
        [exact_matches addObject:candidate];
    }

    if (exact_matches.count > 0) {
        NSInteger best_year_score = NSIntegerMax;
        NSInteger best_episode_score = NSIntegerMax;
        NSMutableSet<NSNumber*>* best_ids = [NSMutableSet new];

        for (NSDictionary* candidate in exact_matches) {
            NSInteger candidate_year = [candidate[@"year"] integerValue];
            NSInteger candidate_episodes = [candidate[@"episodes"] integerValue];
            NSInteger year_score = (year <= 0 || candidate_year <= 0) ? 2 : labs((long)candidate_year - (long)year);
            NSInteger episode_score = (episodes_total <= 0 || candidate_episodes <= 0) ? 1 : 0;

            if (year_score < best_year_score ||
                (year_score == best_year_score && episode_score < best_episode_score)) {
                best_year_score = year_score;
                best_episode_score = episode_score;
                [best_ids removeAllObjects];
                [best_ids addObject:candidate[@"id"]];
            } else if (year_score == best_year_score && episode_score == best_episode_score) {
                [best_ids addObject:candidate[@"id"]];
            }
        }

        // Два равноценных разных MAL ID — неоднозначность, а не повод брать первый.
        return best_ids.count == 1 ? [best_ids.anyObject stringValue] : nil;
    }

    // Совпадение по названию не нашлось: допускаем только единственный результат с точными годом и числом серий.
    if (year > 0 && episodes_total > 0) {
        NSMutableSet<NSNumber*>* metadata_ids = [NSMutableSet new];
        for (NSDictionary* candidate in candidates) {
            if ([candidate[@"id"] longLongValue] > 0 &&
                [candidate[@"year"] integerValue] == year &&
                [candidate[@"episodes"] integerValue] == episodes_total) {
                [metadata_ids addObject:candidate[@"id"]];
            }
        }
        if (metadata_ids.count == 1) {
            return [metadata_ids.anyObject stringValue];
        }
    }
    return nil;
}

/* Публичный API Shikimori: поиск по оригинальному названию, как в Aniko. */
static NSString* ResolveMalIDViaShikimori(NSString* query, NSInteger year, NSInteger episodes_total, BOOL* request_succeeded) {
    if (request_succeeded) {
        *request_succeeded = NO;
    }
    if (query.length == 0) {
        return nil;
    }

    NSMutableCharacterSet* allowed = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowed removeCharactersInString:@"&=+#?%"];
    NSString* encoded = [query stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSURL* url = encoded ? [NSURL URLWithString:[NSString stringWithFormat:@"https://shikimori.one/api/animes?search=%@&limit=8", encoded]] : nil;
    if (!url) {
        return nil;
    }

    NSDictionary* headers = @{
        @"Accept": @"application/json",
        @"User-Agent": @"AniLot"
    };
    NSInteger status = 0;
    NSData* data = SyncGETRetryWithHeaders(url, 3, headers, &status);
    if (status != 200 || !data) {
        NSLog(@"[AniLot AniSkip] Shikimori search failed: HTTP=%ld title=%@", (long)status, query);
        return nil;
    }

    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![json isKindOfClass:[NSArray class]]) {
        NSLog(@"[AniLot AniSkip] Shikimori returned an unexpected response for title=%@", query);
        return nil;
    }
    if (request_succeeded) {
        *request_succeeded = YES;
    }

    NSMutableArray<NSDictionary*>* candidates = [NSMutableArray new];
    for (NSDictionary* item in (NSArray*)json) {
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        long long mal_id = [item[@"id"] longLongValue];
        if (mal_id <= 0) {
            continue;
        }

        NSMutableArray<NSString*>* names = [NSMutableArray new];
        for (NSString* key in @[@"name", @"russian"]) {
            id value = item[key];
            if ([value isKindOfClass:[NSString class]] && [value length] > 0) {
                [names addObject:value];
            }
        }

        NSInteger candidate_episodes = [item[@"episodes"] respondsToSelector:@selector(integerValue)]
            ? [item[@"episodes"] integerValue] : 0;
        [candidates addObject:@{
            @"id": @(mal_id),
            @"names": names,
            @"year": @(ShikimoriYear(item)),
            @"episodes": @(candidate_episodes)
        }];
    }

    NSString* matched = ChooseShikimoriCandidate(candidates, query, year, episodes_total);
    NSLog(@"[AniLot AniSkip] Shikimori: title=%@ year=%ld episodes=%ld candidates=%lu matched=%@",
          query, (long)year, (long)episodes_total, (unsigned long)candidates.count, matched ?: @"none");
    return matched;
}

/* MAL ID кэшируется по релизу. Отрицательный результат повторно ищется через неделю, сетевой сбой не кэшируется. */
static NSString* LookupMalID(anixart::ReleaseID release_id, NSString* title, NSInteger year, NSInteger episodes_total) {
    NSString* cache_key = [NSString stringWithFormat:@"%lld", (long long)static_cast<int64_t>(release_id)];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* cache = [defaults dictionaryForKey:kMalIdsKey];
    id cached_value = cache[cache_key];
    long long cached_id = [cached_value respondsToSelector:@selector(longLongValue)] ? [cached_value longLongValue] : -1;

    if (cached_id > 0) {
        return [NSString stringWithFormat:@"%lld", cached_id];
    }
    if (cached_id == 0) {
        NSDictionary* checked_dates = [defaults dictionaryForKey:kMalIdLookupDatesKey];
        NSTimeInterval checked_at = [checked_dates[cache_key] doubleValue];
        NSTimeInterval age = [NSDate date].timeIntervalSince1970 - checked_at;
        if (checked_at > 0 && age >= 0 && age < kMalIdNotFoundTTL) {
            return nil;
        }
    }

    BOOL request_succeeded = NO;
    NSString* mal_id = ResolveMalIDViaShikimori(title, year, episodes_total, &request_succeeded);
    if (mal_id.length > 0) {
        NSMutableDictionary* updated = [cache mutableCopy] ?: [NSMutableDictionary new];
        updated[cache_key] = mal_id;
        [defaults setObject:updated forKey:kMalIdsKey];
        return mal_id;
    }

    if (request_succeeded) {
        NSMutableDictionary* updated = [cache mutableCopy] ?: [NSMutableDictionary new];
        updated[cache_key] = @0;
        [defaults setObject:updated forKey:kMalIdsKey];

        NSDictionary* checked_dates = [defaults dictionaryForKey:kMalIdLookupDatesKey];
        NSMutableDictionary* updated_dates = [checked_dates mutableCopy] ?: [NSMutableDictionary new];
        updated_dates[cache_key] = @([NSDate date].timeIntervalSince1970);
        [defaults setObject:updated_dates forKey:kMalIdLookupDatesKey];
    }
    return nil;
}

/* Доступ к кэшу MAL ID для синхронизации с Shikimori (anime id в Shikimori совпадает с MAL ID) */
NSString* AniLotLookupMalID(long long release_id, NSString* title, NSInteger year, NSInteger episodes_total) {
    return LookupMalID(anixart::ReleaseID{release_id}, title, year, episodes_total);
}

long long AniLotKnownReleaseIDForMalID(long long mal_id) {
    NSDictionary* cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMalIdsKey];
    for (NSString* key in cache) {
        id value = cache[key];
        if ([value respondsToSelector:@selector(longLongValue)] && [value longLongValue] == mal_id) {
            return key.longLongValue;
        }
    }
    return 0;
}

/* Кэш меток: пропуск работает у скачанных серий без сети и не дёргает AniSkip при каждом запуске. */
static NSDictionary* SkipMarkersCacheEntry(NSString* mal_id, long episode) {
    NSDictionary* cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkipMarkersKey];
    id entry = cache[[NSString stringWithFormat:@"%@-%ld", mal_id, episode]];
    return [entry isKindOfClass:[NSDictionary class]] ? entry : nil;
}

static void StoreSkipMarkers(NSString* mal_id, long episode, NSDictionary* markers) {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* cache = [[defaults dictionaryForKey:kSkipMarkersKey] mutableCopy] ?: [NSMutableDictionary new];
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    cache[[NSString stringWithFormat:@"%@-%ld", mal_id, episode]] = @{@"time": @(now), @"markers": markers ?: @{}};
    if (cache.count > 300) {
        for (NSString* key in cache.allKeys) {
            NSDictionary* entry = cache[key];
            if (![entry isKindOfClass:[NSDictionary class]] || now - [entry[@"time"] doubleValue] > kSkipMarkersPruneAge) {
                [cache removeObjectForKey:key];
            }
        }
    }
    [defaults setObject:cache forKey:kSkipMarkersKey];
}

/* Уже найденный MAL ID релиза (без сети) */
static NSString* CachedMalID(anixart::ReleaseID release_id) {
    NSString* cache_key = [NSString stringWithFormat:@"%lld", (long long)static_cast<int64_t>(release_id)];
    NSDictionary* cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMalIdsKey];
    id cached_value = cache[cache_key];
    long long cached_id = [cached_value respondsToSelector:@selector(longLongValue)] ? [cached_value longLongValue] : 0;
    return cached_id > 0 ? [NSString stringWithFormat:@"%lld", cached_id] : nil;
}

/* Метки из AniSkip: op/ed, mixed-op/mixed-ed (чистые важнее) и recap */
static NSDictionary<NSString*, NSArray<NSNumber*>*>* FetchAniSkipMarkers(NSString* mal_id, long episode) {
    NSDictionary* cached = SkipMarkersCacheEntry(mal_id, episode);
    NSDictionary* cached_markers = [cached[@"markers"] isKindOfClass:[NSDictionary class]] ? cached[@"markers"] : nil;
    if (cached) {
        NSTimeInterval age = [NSDate date].timeIntervalSince1970 - [cached[@"time"] doubleValue];
        NSTimeInterval ttl = cached_markers.count ? kSkipMarkersTTL : kSkipMarkersMissTTL;
        if (age >= 0 && age < ttl) {
            return cached_markers.count ? cached_markers : nil;
        }
    }
    NSString* query = @"types%5B%5D=op&types%5B%5D=ed&types%5B%5D=mixed-op&types%5B%5D=mixed-ed&types%5B%5D=recap&episodeLength=0";
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.aniskip.com/v2/skip-times/%@/%ld?%@", mal_id, episode, query]];
    NSInteger status = 0;
    NSData* data = url ? SyncGETRetry(url, 3, &status) : nil;
    if (status == 404) {
        NSLog(@"[AniLot AniSkip] no timestamps: MAL=%@ episode=%ld", mal_id, (long)episode);
        StoreSkipMarkers(mal_id, episode, @{});
        return nil;
    }
    if (status != 200 || !data) {
        NSLog(@"[AniLot AniSkip] skip-times request failed: MAL=%@ episode=%ld HTTP=%ld", mal_id, (long)episode, (long)status);
        return cached_markers.count ? cached_markers : nil; // нет сети — берём устаревший кэш
    }
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![json isKindOfClass:[NSDictionary class]]) {
        return cached_markers.count ? cached_markers : nil;
    }
    if (![json[@"found"] boolValue]) {
        StoreSkipMarkers(mal_id, episode, @{});
        return nil;
    }
    NSArray* results = json[@"results"];
    if (![results isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableDictionary<NSString*, NSArray<NSNumber*>*>* primary = [NSMutableDictionary new];
    NSMutableDictionary<NSString*, NSArray<NSNumber*>*>* mixed = [NSMutableDictionary new];
    for (NSDictionary* item in results) {
        if (![item isKindOfClass:[NSDictionary class]] || ![item[@"interval"] isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString* type = [item[@"skipType"] description];
        NSString* name = nil;
        if ([type isEqualToString:@"op"] || [type isEqualToString:@"mixed-op"]) {
            name = @"opening";
        } else if ([type isEqualToString:@"ed"] || [type isEqualToString:@"mixed-ed"]) {
            name = @"ending";
        } else if ([type isEqualToString:@"recap"]) {
            name = @"recap";
        }
        double start = [item[@"interval"][@"startTime"] doubleValue];
        double end = [item[@"interval"][@"endTime"] doubleValue];
        if (!name || end <= start) {
            continue;
        }
        NSMutableDictionary<NSString*, NSArray<NSNumber*>*>* target = [type hasPrefix:@"mixed-"] ? mixed : primary;
        if (!target[name]) {
            target[name] = @[@(start), @(end)];
        }
    }
    NSMutableDictionary<NSString*, NSArray<NSNumber*>*>* markers = [NSMutableDictionary new];
    for (NSString* name in @[@"opening", @"ending", @"recap"]) {
        NSArray<NSNumber*>* range = primary[name] ?: mixed[name];
        if (range) {
            markers[name] = range;
        }
    }
    StoreSkipMarkers(mal_id, episode, markers);
    return markers.count ? markers : nil;
}

/* Номер серии из названия. Не берём первое произвольное число: оно может быть номером сезона или частью названия. */
static long EpisodeNumberFromTitle(NSString* title) {
    if (title.length == 0) {
        return 0;
    }
    NSString* name = title;
    NSRange separator = [title rangeOfString:@" · "];
    if (separator.location != NSNotFound) {
        name = [title substringToIndex:separator.location];
    }

    // Сначала явные подписи номера серии.
    NSString* digits = FirstMatch(@"(?:episode|ep\\.?|series|серия|сер\\.?|эпизод)\\s*#?\\s*(\\d{1,4})", name);
    if (digits) {
        return digits.integerValue;
    }

    // Затем обычный формат «01», «01 - ...», «01. ...», «01 серия».
    digits = FirstMatch(@"^\\s*(\\d{1,4})(?:\\s*(?:[-.:)]|серия|эпизод|episode|ep\\.?))", name);
    if (!digits) {
        digits = FirstMatch(@"^\\s*(\\d{1,4})\\s*$", name);
    }
    return digits ? digits.integerValue : 0;
}

static void LoadAniSkipMarkers(anixart::ReleaseID release_id, long position, NSString* episode_title, void (^completion)(NSDictionary<NSString*, NSArray<NSNumber*>*>* markers)) {
    // Position Anixart у разных источников бывает как с нуля, так и с единицы.
    // Используем только явно распознанный номер серии из названия, не угадываем по position.
    long episode = EpisodeNumberFromTitle(episode_title);
    if (episode <= 0) {
        NSLog(@"[AniLot AniSkip] episode number unavailable: release=%lld position=%ld title=%@",
              (long long)static_cast<int64_t>(release_id), position, episode_title ?: @"");
        return;
    }

    void (^fetch)(NSString*) = ^(NSString* mal_id) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            NSDictionary* markers = FetchAniSkipMarkers(mal_id, episode);
            if (markers.count) {
                NSLog(@"[AniLot AniSkip] markers: MAL=%@ episode=%ld opening=%@ ending=%@ recap=%@",
                      mal_id, (long)episode, markers[@"opening"] ?: @"none", markers[@"ending"] ?: @"none", markers[@"recap"] ?: @"none");
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(markers);
                });
            } else {
                NSLog(@"[AniLot AniSkip] no markers: MAL=%@ episode=%ld", mal_id, (long)episode);
            }
        });
    };

    // MAL ID уже известен — метаданные релиза не нужны (работает и без сети, если метки в кэше)
    NSString* cached_mal_id = CachedMalID(release_id);
    if (cached_mal_id.length > 0) {
        fetch(cached_mal_id);
        return;
    }

    __block NSString* title = nil;
    __block NSInteger year = 0;
    __block NSInteger episodes_total = 0;
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        auto release = api->releases().get_release(release_id);
        if (release) {
            title = TO_NSSTRING(release->title_original);
            year = TO_NSSTRING(release->year).integerValue;
            episodes_total = (NSInteger)release->episodes_total;
        }
        return NO;
    } completion:^(BOOL errored) {
        if (errored || title.length == 0) {
            NSLog(@"[AniLot AniSkip] release metadata unavailable: release=%lld errored=%d title=%@",
                  (long long)static_cast<int64_t>(release_id), errored, title ?: @"");
            return;
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            NSString* mal_id = LookupMalID(release_id, title, year, episodes_total);
            if (!mal_id) {
                NSLog(@"[AniLot AniSkip] Shikimori MAL id not found: release=%lld title=%@",
                      (long long)static_cast<int64_t>(release_id), title ?: @"");
                return;
            }
            fetch(mal_id);
        });
    }];
}

static void ResolveStreams(anixart::ReleaseID release_id, anixart::EpisodeSourceID source_id, int32_t position, NSMutableDictionary* markers, NSMutableArray<AniLotSubtitleTrack*>* subtitles, void (^completion)(NSDictionary<NSString*, NSURL*>* urls, NSString* detail)) {
    LibanixartApi* api_proxy = [LibanixartApi sharedInstance];
    __block NSDictionary<NSString*, NSURL*>* result = nil;
    NSMutableString* detail = [NSMutableString new];
    [api_proxy asyncCall:^BOOL(anixart::Api* api) {
        auto ep_target = api->episodes().get_episode_target(release_id, source_id, position);
        std::string target_std = ep_target->url;
        NSString* target = TO_NSSTRING(target_std);
        NSString* lower = target.lowercaseString;
        
        if ([lower containsString:@"libria"] || [lower containsString:@"libert"]) {
            BOOL is_fun = [lower containsString:@"libria.fun"] || [lower containsString:@"iframe.php"];
            if (is_fun) {
                result = ResolveIframeStreams(target, detail, subtitles);
                if (!result.count) {
                    result = ResolveLibriaStreams(target, detail, markers);
                }
            } else {
                result = ResolveLibriaStreams(target, detail, markers);
                if (!result.count) {
                    result = ResolveIframeStreams(target, detail, subtitles);
                }
            }
            if (result.count) {
                return NO;
            }
        }
        if ([lower containsString:@"sibnet"]) {
            result = ResolveSibnetStreams(target, detail, subtitles);
            if (result.count) {
                return NO;
            }
        }
        if ([lower containsString:@".m3u8"]) {
            NSURL* direct = [NSURL URLWithString:target];
            if (direct) {
                result = @{@"auto": direct};
                return NO;
            }
        }
        
        [detail appendFormat:@"Ссылка источника: %@\n", target];
        try {
            auto streams = api_proxy.parsers->extract_info(target_std);
            NSMutableDictionary<NSString*, NSURL*>* dict = [NSMutableDictionary new];
            for (auto& kv : streams) {
                std::string q = kv.first;
                std::string u = kv.second;
                NSURL* url = [NSURL URLWithString:TO_NSSTRING(u)];
                if (url) {
                    dict[TO_NSSTRING(q)] = url;
                }
            }
            result = dict;
        } catch (const std::exception& e) {
            [detail appendFormat:@"Парсер: %s\n", e.what()];
        } catch (...) {
            [detail appendString:@"Парсер: неизвестная ошибка\n"];
        }
        return NO; // asyncCall: YES означает ошибку
    } completion:^(BOOL errored) {
        completion((errored || result.count == 0) ? nil : result, [detail copy]);
    }];
}


static NSString* PreferredQuality(void) {
    return [[[AppDataController sharedInstance] getSettingsController] getPrefferedQuality];
}

static NSTimeInterval DefaultSkipSeconds(void) {
    long long seconds = std::chrono::duration_cast<std::chrono::seconds>([[[AppDataController sharedInstance] getSettingsController] getDefaultSkipTime]).count();
    return seconds > 0 ? (NSTimeInterval)seconds : 90;
}

#pragma mark - Собственный плеер (UI)

static void ShowTopAlert(NSString* title, NSString* message) {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:L(@"app.common.ok", @"OK") style:UIAlertActionStyleDefault handler:nil]];
    [TopViewController() presentViewController:alert animated:YES completion:nil];
}

static void OpenInExternalPlayer(NSString* identifier, NSURL* url) {
    NSMutableCharacterSet* allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:@"-._~"];
    NSString* raw = url.absoluteString;
    NSString* encoded = [raw stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: raw;
    
    if ([identifier isEqualToString:@"share"]) {
        UIViewController* top = TopViewController();
        UIActivityViewController* sheet = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        sheet.popoverPresentationController.sourceView = top.view;
        sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(top.view.bounds), CGRectGetMidY(top.view.bounds), 1, 1);
        [top presentViewController:sheet animated:YES completion:nil];
        return;
    }
    
    NSString* link = nil;
    if ([identifier isEqualToString:@"vlc"]) {
        link = [@"vlc-x-callback://x-callback-url/stream?url=" stringByAppendingString:encoded];
    } else if ([identifier isEqualToString:@"outplayer"]) {
        link = [@"outplayer://" stringByAppendingString:raw];
    } else if ([identifier isEqualToString:@"nplayer"]) {
        link = [@"nplayer-" stringByAppendingString:raw];
    }
    NSURL* scheme_url = link ? [NSURL URLWithString:link] : nil;
    if (!scheme_url) {
        ShowTopAlert(L(@"app.player.external.error", @"Не удалось открыть плеер"), raw);
        return;
    }
    NSString* player_name = AniLotExternalPlayerName(identifier);
    [[UIApplication sharedApplication] openURL:scheme_url options:@{} completionHandler:^(BOOL success) {
        if (!success) {
            ShowTopAlert(L(@"app.player.external.error", @"Не удалось открыть плеер"), [NSString stringWithFormat:@"%@: %@", player_name, L(@"app.player.external.not_installed", @"приложение не установлено или не поддерживает эту ссылку.")]);
        }
    }];
}

@interface PlayerLayerView : UIView
@property(nonatomic, readonly) AVPlayerLayer* playerLayer;
@end
@implementation PlayerLayerView
+(Class)layerClass {
    return [AVPlayerLayer class];
}
-(AVPlayerLayer*)playerLayer {
    return (AVPlayerLayer*)self.layer;
}
@end

static UIButton* IconButton(NSString* symbol, CGFloat point_size) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration* conf = [UIImageSymbolConfiguration configurationWithPointSize:point_size weight:UIImageSymbolWeightSemibold];
    [button setImage:[UIImage systemImageNamed:symbol withConfiguration:conf] forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

@interface AniLotPlayerViewController : UIViewController
@property(nonatomic, strong) AVPlayer* player;
@property(nonatomic, copy) NSString* video_title;
@property(nonatomic) NSTimeInterval skip_seconds;
@property(nonatomic, copy) NSDictionary<NSString*, NSURL*>* quality_urls;
@property(nonatomic, copy) NSString* current_quality;
@property(nonatomic, copy) NSString* resume_key;
@property(nonatomic, copy) NSDictionary<NSString*, NSArray<NSNumber*>*>* markers;
@property(nonatomic, copy) void (^pip_will_start)(AniLotPlayerViewController* controller);
@property(nonatomic, copy) void (^pip_restore)(AniLotPlayerViewController* controller, void (^completion)(BOOL restored));
@property(nonatomic, copy) void (^pip_did_stop)(AniLotPlayerViewController* controller);
/* контекст воспроизведения сетевой серии — нужен для автоперехода на следующую серию */
@property(nonatomic) long long ctx_release_id;
@property(nonatomic) long long ctx_source_id;
@property(nonatomic) long ctx_position;
@property(nonatomic, copy) NSArray<NSDictionary*>* playlist; // @{position, title}, по возрастанию
@property(nonatomic, copy) void (^on_finished)(AniLotPlayerViewController* controller);
/* внешние дорожки субтитров, найденные в источнике (файлы .vtt/.srt/.ass) */
@property(nonatomic, copy) NSArray<AniLotSubtitleTrack*>* external_subtitles;

-(void)prepareForNextEpisodeWithTitle:(NSString*)title resumeKey:(NSString*)resume_key;
-(void)showToast:(NSString*)text;
-(void)mergeMarkers:(NSDictionary<NSString*, NSArray<NSNumber*>*>*)markers overwrite:(BOOL)overwrite;
-(void)startWithURL:(NSURL*)url;
-(void)configureWithQualities:(NSDictionary<NSString*, NSURL*>*)urls preferred:(NSString*)preferred;
-(void)configureSubtitles:(NSArray<AniLotSubtitleTrack*>*)tracks;
-(void)showMessage:(NSString*)title message:(NSString*)message closeAfter:(BOOL)close_after;
-(void)stopPlayback;
@end

@interface AniLotPlayerViewController () <AVPictureInPictureControllerDelegate, AVPlayerItemLegibleOutputPushDelegate> {
    AVPictureInPictureController* _pip;
    double _skip_target;
    double _last_saved;
    BOOL _resume_applied;
    NSMutableSet<NSString*>* _auto_skipped;
    id _time_observer;
    id _end_observer;
    BOOL _scrubbing;
    float _rate;
    BOOL _overlay_visible;
    BOOL _error_shown;
    NSTimer* _poll_timer;
    NSURL* _pending_url;
    // субтитры
    AVPlayerItemLegibleOutput* _legible_output;
    AVMediaSelectionGroup* _legible_group;
    NSArray<AVMediaSelectionOption*>* _legible_options;
    AVMediaSelectionOption* _selected_embedded;
    AniLotSubtitleTrack* _active_external;
    id _subtitle_observer;
    NSString* _last_subtitle_text;
    NSLayoutConstraint* _subtitle_bottom;
}
@property(nonatomic, strong) PlayerLayerView* video_view;
@property(nonatomic, strong) UIView* overlay;
@property(nonatomic, strong) UILabel* title_label;
@property(nonatomic, strong) UIButton* close_button;
@property(nonatomic, strong) UIButton* quality_button;
@property(nonatomic, strong) UIButton* speed_button;
@property(nonatomic, strong) UIButton* play_button;
@property(nonatomic, strong) UIButton* back_button;
@property(nonatomic, strong) UIButton* forward_button;
@property(nonatomic, strong) UISlider* slider;
@property(nonatomic, strong) UILabel* current_label;
@property(nonatomic, strong) UILabel* duration_label;
@property(nonatomic, strong) UIActivityIndicatorView* spinner;
@property(nonatomic, strong) UIButton* pip_button;
@property(nonatomic, strong) UIButton* skip_button;
@property(nonatomic, strong) UILabel* toast_label;
@property(nonatomic, strong) UIButton* subtitle_button;
@property(nonatomic, strong) UILabel* subtitle_label;
@end

@implementation AniLotPlayerViewController

-(instancetype)init {
    self = [super init];
    _rate = 1.0f;
    _skip_seconds = 90;
    _overlay_visible = YES;
    _auto_skipped = [NSMutableSet new];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

-(void)dealloc {
    [self stopPlayback];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}
-(BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(UILabel*)makeTimeLabel {
    UILabel* label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium];
    label.text = @"0:00";
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _video_view = [PlayerLayerView new];
    _video_view.translatesAutoresizingMaskIntoConstraints = NO;
    _video_view.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view addSubview:_video_view];
    
    _overlay = [UIView new];
    _overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    _overlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_overlay];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _spinner.color = [UIColor whiteColor];
    _spinner.translatesAutoresizingMaskIntoConstraints = NO;
    _spinner.hidesWhenStopped = YES;
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
    
    // верхняя панель
    _close_button = IconButton(@"xmark", 20);
    [_close_button addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    
    _title_label = [UILabel new];
    _title_label.textColor = [UIColor whiteColor];
    _title_label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _title_label.text = _video_title;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    
    _speed_button = IconButton(@"speedometer", 20);
    _speed_button.showsMenuAsPrimaryAction = YES;
    _quality_button = IconButton(@"gearshape.fill", 20);
    _quality_button.showsMenuAsPrimaryAction = YES;
    _pip_button = IconButton(@"pip.enter", 20);
    [_pip_button addTarget:self action:@selector(onPiP) forControlEvents:UIControlEventTouchUpInside];
    _pip_button.hidden = ![AVPictureInPictureController isPictureInPictureSupported];
    _subtitle_button = IconButton(@"captions.bubble", 20);
    _subtitle_button.showsMenuAsPrimaryAction = YES;
    _subtitle_button.hidden = YES;
    
    // центр
    _back_button = IconButton(@"gobackward", 34);
    [_back_button addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    _play_button = IconButton(@"pause.fill", 46);
    [_play_button addTarget:self action:@selector(onPlayPause) forControlEvents:UIControlEventTouchUpInside];
    _forward_button = IconButton(@"goforward", 34);
    [_forward_button addTarget:self action:@selector(onForward) forControlEvents:UIControlEventTouchUpInside];
    
    NSString* skip_text = [NSString stringWithFormat:@"%ld", (long)_skip_seconds];
    for (UIButton* b in @[_back_button, _forward_button]) {
        UILabel* l = [UILabel new];
        l.text = skip_text;
        l.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        l.textColor = [UIColor whiteColor];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.userInteractionEnabled = NO;
        [b addSubview:l];
        [NSLayoutConstraint activateConstraints:@[
            [l.centerXAnchor constraintEqualToAnchor:b.centerXAnchor],
            [l.centerYAnchor constraintEqualToAnchor:b.centerYAnchor constant:1]
        ]];
    }
    
    UIStackView* center_stack = [[UIStackView alloc] initWithArrangedSubviews:@[_back_button, _play_button, _forward_button]];
    center_stack.axis = UILayoutConstraintAxisHorizontal;
    center_stack.spacing = 48;
    center_stack.alignment = UIStackViewAlignmentCenter;
    center_stack.translatesAutoresizingMaskIntoConstraints = NO;
    
    // нижняя панель
    _current_label = [self makeTimeLabel];
    _duration_label = [self makeTimeLabel];
    _slider = [UISlider new];
    _slider.minimumTrackTintColor = [AppColorProvider primaryColor];
    _slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    [_slider addTarget:self action:@selector(onScrubStart) forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self action:@selector(onScrubChanged) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(onScrubEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    [_overlay addSubview:_close_button];
    [_overlay addSubview:_title_label];
    [_overlay addSubview:_speed_button];
    [_overlay addSubview:_pip_button];
    [_overlay addSubview:_subtitle_button];
    [_overlay addSubview:_quality_button];
    [_overlay addSubview:center_stack];
    [_overlay addSubview:_current_label];
    [_overlay addSubview:_slider];
    [_overlay addSubview:_duration_label];
    
    _skip_button = [UIButton buttonWithType:UIButtonTypeSystem];
    _skip_button.translatesAutoresizingMaskIntoConstraints = NO;
    _skip_button.tintColor = [UIColor whiteColor];
    _skip_button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _skip_button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    _skip_button.layer.cornerRadius = 18;
    _skip_button.layer.borderWidth = 1;
    _skip_button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    _skip_button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    _skip_button.hidden = YES;
    [_skip_button addTarget:self action:@selector(onSkipTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_skip_button];
    
    _toast_label = [UILabel new];
    _toast_label.translatesAutoresizingMaskIntoConstraints = NO;
    _toast_label.textColor = [UIColor whiteColor];
    _toast_label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _toast_label.textAlignment = NSTextAlignmentCenter;
    _toast_label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _toast_label.layer.cornerRadius = 14;
    _toast_label.layer.masksToBounds = YES;
    _toast_label.alpha = 0;
    [self.view addSubview:_toast_label];
    
    // Субтитры рисуем сами: AVPlayerLayer не показывает дорожки субтитров
    _subtitle_label = [UILabel new];
    _subtitle_label.translatesAutoresizingMaskIntoConstraints = NO;
    _subtitle_label.numberOfLines = 0;
    _subtitle_label.textAlignment = NSTextAlignmentCenter;
    _subtitle_label.userInteractionEnabled = NO;
    _subtitle_label.hidden = YES;
    [self.view addSubview:_subtitle_label];
    
    UILayoutGuide* safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_video_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_video_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_video_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_video_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [_overlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_overlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_overlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_overlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [_spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [_close_button.topAnchor constraintEqualToAnchor:safe.topAnchor constant:8],
        [_close_button.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:12],
        [_close_button.widthAnchor constraintEqualToConstant:44],
        [_close_button.heightAnchor constraintEqualToConstant:44],
        
        [_quality_button.centerYAnchor constraintEqualToAnchor:_close_button.centerYAnchor],
        [_quality_button.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-12],
        [_quality_button.widthAnchor constraintEqualToConstant:44],
        [_quality_button.heightAnchor constraintEqualToConstant:44],
        [_speed_button.centerYAnchor constraintEqualToAnchor:_close_button.centerYAnchor],
        [_speed_button.trailingAnchor constraintEqualToAnchor:_quality_button.leadingAnchor constant:-4],
        [_speed_button.widthAnchor constraintEqualToConstant:44],
        [_speed_button.heightAnchor constraintEqualToConstant:44],
        
        [_title_label.centerYAnchor constraintEqualToAnchor:_close_button.centerYAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_close_button.trailingAnchor constant:8],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:_subtitle_button.leadingAnchor constant:-8],
        
        [center_stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [center_stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [_current_label.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [_current_label.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-16],
        [_duration_label.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [_duration_label.bottomAnchor constraintEqualToAnchor:_current_label.bottomAnchor],
        [_slider.leadingAnchor constraintEqualToAnchor:_current_label.trailingAnchor constant:10],
        [_slider.trailingAnchor constraintEqualToAnchor:_duration_label.leadingAnchor constant:-10],
        [_slider.centerYAnchor constraintEqualToAnchor:_current_label.centerYAnchor],
        
        [_pip_button.centerYAnchor constraintEqualToAnchor:_close_button.centerYAnchor],
        [_pip_button.trailingAnchor constraintEqualToAnchor:_speed_button.leadingAnchor constant:-4],
        [_pip_button.widthAnchor constraintEqualToConstant:44],
        [_pip_button.heightAnchor constraintEqualToConstant:44],
        
        [_subtitle_button.centerYAnchor constraintEqualToAnchor:_close_button.centerYAnchor],
        [_subtitle_button.trailingAnchor constraintEqualToAnchor:_pip_button.leadingAnchor constant:-4],
        [_subtitle_button.widthAnchor constraintEqualToConstant:44],
        [_subtitle_button.heightAnchor constraintEqualToConstant:44],
        
        [_subtitle_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_subtitle_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:safe.leadingAnchor constant:48],
        [_subtitle_label.trailingAnchor constraintLessThanOrEqualToAnchor:safe.trailingAnchor constant:-48],
        
        [_skip_button.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [_skip_button.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-68],
        [_skip_button.heightAnchor constraintEqualToConstant:36],
        
        [_toast_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_toast_label.topAnchor constraintEqualToAnchor:_close_button.bottomAnchor constant:10],
        [_toast_label.heightAnchor constraintEqualToConstant:28],
        [_toast_label.widthAnchor constraintGreaterThanOrEqualToConstant:120]
    ]];
    
    _subtitle_bottom = [_subtitle_label.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-72];
    _subtitle_bottom.active = YES;
    
    UITapGestureRecognizer* double_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    double_tap.numberOfTapsRequired = 2;
    UITapGestureRecognizer* single_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [single_tap requireGestureRecognizerToFail:double_tap];
    [self.view addGestureRecognizer:double_tap];
    [self.view addGestureRecognizer:single_tap];
    
    [self rebuildMenus];
    if (_pending_url) {
        NSURL* url = _pending_url;
        _pending_url = nil;
        [self beginPlaybackWithURL:url];
    }
}

#pragma mark Воспроизведение

-(void)mergeMarkers:(NSDictionary<NSString*, NSArray<NSNumber*>*>*)markers overwrite:(BOOL)overwrite {
    NSMutableDictionary* merged = [(_markers ?: @{}) mutableCopy];
    for (NSString* key in markers) {
        if (overwrite || !merged[key]) {
            merged[key] = markers[key];
        }
    }
    self.markers = merged;
}

-(void)startWithURL:(NSURL*)url {
    if (self.isViewLoaded) {
        [self beginPlaybackWithURL:url];
    } else {
        _pending_url = url;
    }
}

-(void)configureWithQualities:(NSDictionary<NSString*, NSURL*>*)urls preferred:(NSString*)preferred {
    _quality_urls = [urls copy];
    _current_quality = ChooseQualityName(urls, preferred);
    if (self.isViewLoaded) {
        [self rebuildMenus];
    }
    [self startWithURL:urls[_current_quality]];
}

-(void)beginPlaybackWithURL:(NSURL*)url {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [self stopPlayback];
    _error_shown = NO;
    _resume_applied = NO;
    _last_saved = 0;
    [_auto_skipped removeAllObjects];
    if (url.isFileURL) {
        _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:url options:nil]]];
    } else {
        NSDictionary<NSString*, NSString*>* headers = HeadersForStream(url);
        if (headers.count) {
            _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:url options:@{@"AVURLAssetHTTPHeaderFieldsKey": headers}]]];
        } else {
            _player = [AVPlayer playerWithURL:url];
        }
    }
    _video_view.playerLayer.player = _player;
    [self setupSubtitlesForCurrentItem];
    
    _pip = nil;
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        _pip = [[AVPictureInPictureController alloc] initWithPlayerLayer:_video_view.playerLayer];
        _pip.delegate = self;
        if (@available(iOS 14.2, *)) {
            _pip.canStartPictureInPictureAutomaticallyFromInline = YES;
        }
    }
    _pip_button.hidden = (_pip == nil);
    
    __weak AniLotPlayerViewController* weak_self = self;
    _time_observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weak_self updateUI];
    }];
    _subtitle_observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weak_self refreshExternalSubtitleAtTime:CMTimeGetSeconds(time)];
    }];
    _end_observer = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* note) {
        AniLotPlayerViewController* strong_self = weak_self;
        if (!strong_self || note.object != strong_self.player.currentItem) {
            return;
        }
        if (strong_self.resume_key.length) {
            ClearPosition(strong_self.resume_key);
        }
        [strong_self setOverlayVisible:YES];
        [strong_self updateUI];
        // «Автоматически следующая серия»
        if (strong_self.on_finished && [[[AppDataController sharedInstance] getSettingsController] getAutoNextVideo]) {
            strong_self.on_finished(strong_self);
        }
    }];
    _poll_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer* timer) {
        [weak_self updateUI];
    }];
    [_player playImmediatelyAtRate:_rate];
    [self updateUI];
    [self scheduleHide];
}

-(void)prepareForNextEpisodeWithTitle:(NSString*)title resumeKey:(NSString*)resume_key {
    [self stopPlayback]; // фиксирует позицию предыдущей серии
    self.player = nil;
    self.video_title = title;
    _title_label.text = title;
    self.resume_key = resume_key;
    self.markers = @{};
    [self resetSubtitles];
    [_auto_skipped removeAllObjects];
    _skip_button.hidden = YES;
    _slider.value = 0;
    [_spinner startAnimating];
    [self setOverlayVisible:YES];
    [self showToast:[NSString stringWithFormat:@"%@: %@", L(@"app.player.next_episode", @"Следующая серия"), title ?: @""]];
}

-(void)stopPlayback {
    if (_player && _resume_key.length && AniLotSettingBool(AniLotSettingResumeKey, YES)) {
        double current = CMTimeGetSeconds(_player.currentTime);
        double duration = CMTimeGetSeconds(_player.currentItem.duration);
        if (isfinite(current) && isfinite(duration) && duration > 0 && current > 5) {
            if (duration - current < 30) {
                ClearPosition(_resume_key);
            } else {
                SavePosition(_resume_key, current);
            }
        }
    }
    [_poll_timer invalidate];
    _poll_timer = nil;
    if (_time_observer) {
        [_player removeTimeObserver:_time_observer];
        _time_observer = nil;
    }
    if (_subtitle_observer) {
        [_player removeTimeObserver:_subtitle_observer];
        _subtitle_observer = nil;
    }
    if (_end_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_end_observer];
        _end_observer = nil;
    }
    [_player pause];
}

-(void)updateUI {
    AVPlayerItem* item = _player.currentItem;
    double duration = CMTimeGetSeconds(item.duration);
    double current = CMTimeGetSeconds(_player.currentTime);
    BOOL has_duration = isfinite(duration) && duration > 0;
    if (!_scrubbing) {
        _slider.value = has_duration ? (float)(current / duration) : 0;
        _current_label.text = FormatTime(current);
    }
    _duration_label.text = has_duration ? FormatTime(duration) : @"--:--";
    
    if (item.status == AVPlayerItemStatusFailed && !_error_shown) {
        _error_shown = YES;
        [_spinner stopAnimating];
        NSString* reason = item.error.localizedDescription ?: @"";
        [self showMessage:L(@"app.player.playback_error", @"Не удалось воспроизвести видео") message:reason closeAfter:NO];
        return;
    }
    BOOL waiting = _player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate || item.status == AVPlayerItemStatusUnknown;
    if (waiting) {
        [_spinner startAnimating];
    } else {
        [_spinner stopAnimating];
    }
    BOOL playing = _player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    UIImageSymbolConfiguration* conf = [UIImageSymbolConfiguration configurationWithPointSize:46 weight:UIImageSymbolWeightSemibold];
    [_play_button setImage:[UIImage systemImageNamed:(playing || waiting) ? @"pause.fill" : @"play.fill" withConfiguration:conf] forState:UIControlStateNormal];
    [self handleSkipAndResumeWithCurrent:current duration:duration hasDuration:has_duration playing:playing];
}

#pragma mark Позиция, пропуск, PiP

-(void)showToast:(NSString*)text {
    _toast_label.text = [NSString stringWithFormat:@"  %@  ", text];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToast) object:nil];
    [UIView animateWithDuration:0.2 animations:^{
        self.toast_label.alpha = 1;
    }];
    [self performSelector:@selector(hideToast) withObject:nil afterDelay:2.5];
}
-(void)hideToast {
    [UIView animateWithDuration:0.3 animations:^{
        self.toast_label.alpha = 0;
    }];
}

-(void)handleSkipAndResumeWithCurrent:(double)current duration:(double)duration hasDuration:(BOOL)has_duration playing:(BOOL)playing {
    AVPlayerItem* item = _player.currentItem;
    BOOL resume_enabled = AniLotSettingBool(AniLotSettingResumeKey, YES);
    
    // возобновление с сохранённой позиции
    if (!_resume_applied && item.status == AVPlayerItemStatusReadyToPlay && has_duration) {
        _resume_applied = YES;
        if (resume_enabled && _resume_key.length) {
            double saved = SavedPosition(_resume_key);
            if (saved > 10 && saved < duration - 30) {
                [_player seekToTime:CMTimeMakeWithSeconds(saved, 600)];
                [self showToast:[NSString stringWithFormat:@"%@ %@", L(@"app.player.resumed", @"Продолжено с"), FormatTime(saved)]];
                return;
            }
        }
    }
    
    // сохранение позиции каждые несколько секунд
    if (resume_enabled && _resume_key.length && has_duration && playing && current > 5 && fabs(current - _last_saved) >= 5) {
        _last_saved = current;
        if (duration - current < 30) {
            ClearPosition(_resume_key);
        } else {
            SavePosition(_resume_key, current);
        }
    }
    
    // пропуск рекапа / опенинга / эндинга
    BOOL show_buttons = AniLotSettingBool(AniLotSettingSkipButtonsKey, YES);
    BOOL auto_skip = AniLotSettingBool(AniLotSettingAutoSkipKey, NO);
    NSString* title = nil;
    NSString* marker_name = nil;
    double target = 0;
    for (NSString* name in @[@"recap", @"opening", @"ending"]) {
        NSArray<NSNumber*>* range = _markers[name];
        if (range.count == 2 && range[1].doubleValue > range[0].doubleValue && current >= range[0].doubleValue - 0.5 && current < range[1].doubleValue - 1) {
            marker_name = name;
            target = range[1].doubleValue;
            if ([name isEqualToString:@"opening"]) {
                title = L(@"app.player.skip_opening", @"Пропустить опенинг");
            } else if ([name isEqualToString:@"ending"]) {
                title = L(@"app.player.skip_ending", @"Пропустить эндинг");
            } else {
                title = L(@"app.player.skip_recap", @"Пропустить рекап");
            }
            break;
        }
    }
    if (marker_name && auto_skip && ![_auto_skipped containsObject:marker_name]) {
        [_auto_skipped addObject:marker_name];
        [_player seekToTime:CMTimeMakeWithSeconds(target, 600)];
        [self showToast:title];
        _skip_button.hidden = YES;
        return;
    }
    if (title && show_buttons) {
        [_skip_button setTitle:title forState:UIControlStateNormal];
        _skip_target = target;
        _skip_button.hidden = NO;
    } else {
        _skip_button.hidden = YES;
    }
}

-(void)onSkipTapped {
    [_player seekToTime:CMTimeMakeWithSeconds(_skip_target, 600)];
    _skip_button.hidden = YES;
}

-(void)onPiP {
    if (_pip.isPictureInPictureActive) {
        [_pip stopPictureInPicture];
    } else if (_pip.isPictureInPicturePossible) {
        [_pip startPictureInPicture];
    } else {
        [self showToast:L(@"app.player.pip_unavailable", @"Картинка в картинке пока недоступна")];
    }
}

-(void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController*)controller {
    if (_pip_will_start) {
        _pip_will_start(self);
    }
}
-(void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController*)controller {
    if (_pip_did_stop) {
        _pip_did_stop(self);
    }
}
-(void)pictureInPictureController:(AVPictureInPictureController*)controller restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completion_handler {
    if (_pip_restore) {
        _pip_restore(self, completion_handler);
    } else {
        completion_handler(YES);
    }
}

-(void)seekBy:(NSTimeInterval)delta {
    double duration = CMTimeGetSeconds(_player.currentItem.duration);
    double target = CMTimeGetSeconds(_player.currentTime) + delta;
    if (isfinite(duration)) {
        target = MIN(target, duration);
    }
    target = MAX(target, 0);
    [_player seekToTime:CMTimeMakeWithSeconds(target, 600)];
    [self scheduleHide];
}

#pragma mark Меню

-(void)rebuildMenus {
    __weak AniLotPlayerViewController* weak_self = self;
    
    NSArray<NSNumber*>* rates = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0];
    NSMutableArray<UIMenuElement*>* speed_actions = [NSMutableArray new];
    for (NSNumber* r in rates) {
        NSString* title = [NSString stringWithFormat:@"%gx", r.floatValue];
        UIAction* action = [UIAction actionWithTitle:title image:nil identifier:nil handler:^(UIAction* a) {
            AniLotPlayerViewController* s = weak_self;
            if (!s) return;
            s->_rate = r.floatValue;
            if (s.player.timeControlStatus != AVPlayerTimeControlStatusPaused) {
                [s.player playImmediatelyAtRate:s->_rate];
            }
            [s rebuildMenus];
        }];
        action.state = fabsf(r.floatValue - _rate) < 0.001f ? UIMenuElementStateOn : UIMenuElementStateOff;
        [speed_actions addObject:action];
    }
    _speed_button.menu = [UIMenu menuWithTitle:L(@"app.player.speed", @"Скорость") children:speed_actions];
    
    NSMutableArray<UIMenuElement*>* quality_actions = [NSMutableArray new];
    for (NSString* name in SortedQualityNames(_quality_urls ?: @{})) {
        UIAction* action = [UIAction actionWithTitle:QualityTitle(name) image:nil identifier:nil handler:^(UIAction* a) {
            [weak_self switchToQuality:name];
        }];
        action.state = [name isEqualToString:_current_quality] ? UIMenuElementStateOn : UIMenuElementStateOff;
        [quality_actions addObject:action];
    }
    _quality_button.hidden = quality_actions.count < 2;
    _quality_button.menu = [UIMenu menuWithTitle:L(@"app.player.quality", @"Качество") children:quality_actions];
    
    // субтитры: дорожки из HLS-манифеста и внешние файлы источника
    NSMutableArray<UIMenuElement*>* subtitle_actions = [NSMutableArray new];
    UIAction* off_action = [UIAction actionWithTitle:L(@"app.player.subtitles.off", @"Выключены") image:nil identifier:nil handler:^(UIAction* a) {
        [weak_self selectEmbeddedSubtitle:nil external:nil];
    }];
    off_action.state = (!_selected_embedded && !_active_external) ? UIMenuElementStateOn : UIMenuElementStateOff;
    [subtitle_actions addObject:off_action];
    for (AVMediaSelectionOption* option in _legible_options) {
        UIAction* action = [UIAction actionWithTitle:option.displayName ?: L(@"app.player.subtitles.generic", @"Субтитры") image:nil identifier:nil handler:^(UIAction* a) {
            [weak_self selectEmbeddedSubtitle:option external:nil];
        }];
        action.state = (_selected_embedded == option) ? UIMenuElementStateOn : UIMenuElementStateOff;
        [subtitle_actions addObject:action];
    }
    for (AniLotSubtitleTrack* track in _external_subtitles) {
        UIAction* action = [UIAction actionWithTitle:track.label image:nil identifier:nil handler:^(UIAction* a) {
            [weak_self selectEmbeddedSubtitle:nil external:track];
        }];
        action.state = (_active_external == track) ? UIMenuElementStateOn : UIMenuElementStateOff;
        [subtitle_actions addObject:action];
    }
    _subtitle_button.hidden = (_legible_options.count + _external_subtitles.count) == 0;
    _subtitle_button.menu = [UIMenu menuWithTitle:L(@"app.player.subtitles", @"Субтитры") children:subtitle_actions];
    BOOL subtitles_on = (_selected_embedded != nil || _active_external != nil);
    UIImageSymbolConfiguration* subtitle_conf = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightSemibold];
    [_subtitle_button setImage:[UIImage systemImageNamed:subtitles_on ? @"captions.bubble.fill" : @"captions.bubble" withConfiguration:subtitle_conf] forState:UIControlStateNormal];
}

-(void)switchToQuality:(NSString*)name {
    NSURL* url = _quality_urls[name];
    if (!url || [name isEqualToString:_current_quality]) {
        return;
    }
    CMTime time = _player.currentTime;
    BOOL was_paused = _player.timeControlStatus == AVPlayerTimeControlStatusPaused;
    _current_quality = name;
    _error_shown = NO;
    [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    [self setupSubtitlesForCurrentItem];
    [_player seekToTime:time];
    if (!was_paused) {
        [_player playImmediatelyAtRate:_rate];
    }
    [self rebuildMenus];
}

#pragma mark Субтитры

-(void)configureSubtitles:(NSArray<AniLotSubtitleTrack*>*)tracks {
    _external_subtitles = [tracks copy] ?: @[];
    if (_active_external && ![_external_subtitles containsObject:_active_external]) {
        _active_external = nil;
    }
    if (self.isViewLoaded) {
        [self autoSelectSubtitleIfNeeded];
        [self rebuildMenus];
    }
}

-(void)resetSubtitles {
    _external_subtitles = @[];
    _active_external = nil;
    _selected_embedded = nil;
    _legible_group = nil;
    _legible_options = @[];
    _legible_output = nil;
    [self setSubtitleText:nil];
    if (self.isViewLoaded) {
        [self rebuildMenus];
    }
}

/* Подключает вывод субтитров к текущему элементу и ищет в нём встроенные дорожки (HLS EXT-X-MEDIA TYPE=SUBTITLES) */
-(void)setupSubtitlesForCurrentItem {
    _legible_group = nil;
    _legible_options = @[];
    _selected_embedded = nil;
    _legible_output = nil;
    [self setSubtitleText:nil];
    AVPlayerItem* item = _player.currentItem;
    if (!item) {
        return;
    }
    _legible_output = [[AVPlayerItemLegibleOutput alloc] initWithMediaSubtypesForNativeRepresentation:@[]];
    _legible_output.suppressesPlayerRendering = YES;
    [_legible_output setDelegate:self queue:dispatch_get_main_queue()];
    [item addOutput:_legible_output];
    
    __weak AniLotPlayerViewController* weak_self = self;
    __weak AVPlayerItem* weak_item = item;
    void (^handle_group)(AVMediaSelectionGroup*) = ^(AVMediaSelectionGroup* group) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AniLotPlayerViewController* strong_self = weak_self;
            if (!strong_self || strong_self.player.currentItem != weak_item || !group) {
                return;
            }
            strong_self->_legible_group = group;
            strong_self->_legible_options = [AVMediaSelectionGroup mediaSelectionOptionsFromArray:group.options withoutMediaCharacteristics:@[AVMediaCharacteristicContainsOnlyForcedSubtitles]];
            [strong_self autoSelectSubtitleIfNeeded];
            [strong_self rebuildMenus];
        });
    };
    AVAsset* asset = item.asset;
    if (@available(iOS 15.0, *)) {
        [asset loadMediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible completionHandler:^(AVMediaSelectionGroup* group, NSError* error) {
            handle_group(group);
        }];
    } else {
        [asset loadValuesAsynchronouslyForKeys:@[@"availableMediaCharacteristicsWithMediaSelectionOptions"] completionHandler:^{
            handle_group([asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible]);
        }];
    }
    [self autoSelectSubtitleIfNeeded];
    [self rebuildMenus];
}

/* Если пользователь раньше выбрал дорожку (например, «Русский»), включаем такую же в следующих сериях */
-(void)autoSelectSubtitleIfNeeded {
    if (_active_external || _selected_embedded) {
        return;
    }
    NSString* wanted = [[NSUserDefaults standardUserDefaults] stringForKey:kSubtitleLabelKey];
    if (wanted.length == 0) {
        return;
    }
    for (AVMediaSelectionOption* option in _legible_options) {
        if ([option.displayName isEqualToString:wanted]) {
            [self applySubtitleEmbedded:option external:nil remember:NO];
            return;
        }
    }
    for (AniLotSubtitleTrack* track in _external_subtitles) {
        if ([track.label isEqualToString:wanted]) {
            [self applySubtitleEmbedded:nil external:track remember:NO];
            return;
        }
    }
}

-(void)selectEmbeddedSubtitle:(AVMediaSelectionOption*)option external:(AniLotSubtitleTrack*)track {
    [self applySubtitleEmbedded:option external:track remember:YES];
}

-(void)applySubtitleEmbedded:(AVMediaSelectionOption*)option external:(AniLotSubtitleTrack*)track remember:(BOOL)remember {
    _selected_embedded = option;
    _active_external = track;
    AVPlayerItem* item = _player.currentItem;
    if (item && _legible_group) {
        [item selectMediaOption:option inMediaSelectionGroup:_legible_group];
    }
    [self setSubtitleText:nil];
    if (remember) {
        NSString* label = option ? option.displayName : track.label;
        [[NSUserDefaults standardUserDefaults] setObject:label ?: @"" forKey:kSubtitleLabelKey];
    }
    if (track && track.cues == nil) {
        [self showToast:L(@"app.player.subtitles.loading", @"Загрузка субтитров…")];
        __weak AniLotPlayerViewController* weak_self = self;
        [track loadWithCompletion:^(BOOL ok) {
            AniLotPlayerViewController* strong_self = weak_self;
            if (!strong_self || strong_self->_active_external != track) {
                return;
            }
            if (!ok) {
                strong_self->_active_external = nil;
                [strong_self showToast:L(@"app.player.subtitles.failed", @"Не удалось загрузить субтитры")];
                [strong_self rebuildMenus];
                return;
            }
            [strong_self refreshExternalSubtitleAtTime:CMTimeGetSeconds(strong_self.player.currentTime)];
        }];
    }
    [self rebuildMenus];
    [self scheduleHide];
}

-(void)refreshExternalSubtitleAtTime:(double)time {
    if (!_active_external) {
        return;
    }
    [self setSubtitleText:[_active_external textAtTime:time]];
}

-(void)setSubtitleText:(NSString*)text {
    NSString* trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        if (_last_subtitle_text != nil || !_subtitle_label.hidden) {
            _last_subtitle_text = nil;
            _subtitle_label.attributedText = nil;
            _subtitle_label.hidden = YES;
        }
        return;
    }
    if ([trimmed isEqualToString:_last_subtitle_text]) {
        return;
    }
    _last_subtitle_text = trimmed;
    NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary* attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSStrokeColorAttributeName: [UIColor blackColor],
        NSStrokeWidthAttributeName: @(-4.0),
        NSParagraphStyleAttributeName: paragraph
    };
    _subtitle_label.attributedText = [[NSAttributedString alloc] initWithString:trimmed attributes:attributes];
    _subtitle_label.hidden = NO;
}

/* Встроенные субтитры (HLS): AVPlayerLayer сам их не рисует, получаем текст и показываем в subtitle_label */
-(void)legibleOutput:(AVPlayerItemLegibleOutput*)output didOutputAttributedStrings:(NSArray<NSAttributedString*>*)strings nativeSampleBuffers:(NSArray*)native_samples forItemTime:(CMTime)item_time {
    if (output != _legible_output || _active_external || !_selected_embedded) {
        return;
    }
    NSMutableArray<NSString*>* lines = [NSMutableArray new];
    for (NSAttributedString* string in strings) {
        NSString* line = [string.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length) {
            [lines addObject:line];
        }
    }
    [self setSubtitleText:[lines componentsJoinedByString:@"\n"]];
}

#pragma mark Действия

-(void)onClose {
    [self stopPlayback];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)onPlayPause {
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        double duration = CMTimeGetSeconds(_player.currentItem.duration);
        if (isfinite(duration) && CMTimeGetSeconds(_player.currentTime) >= duration - 0.5) {
            [_player seekToTime:kCMTimeZero];
        }
        [_player playImmediatelyAtRate:_rate];
    } else {
        [_player pause];
    }
    [self updateUI];
    [self scheduleHide];
}
-(void)onBack {
    [self seekBy:-_skip_seconds];
}
-(void)onForward {
    [self seekBy:_skip_seconds];
}
-(void)onScrubStart {
    _scrubbing = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOverlay) object:nil];
}
-(void)onScrubChanged {
    double duration = CMTimeGetSeconds(_player.currentItem.duration);
    if (isfinite(duration)) {
        _current_label.text = FormatTime(_slider.value * duration);
    }
}
-(void)onScrubEnd {
    double duration = CMTimeGetSeconds(_player.currentItem.duration);
    if (isfinite(duration) && duration > 0) {
        [_player seekToTime:CMTimeMakeWithSeconds(_slider.value * duration, 600)];
    }
    _scrubbing = NO;
    [self scheduleHide];
}
-(void)onSingleTap {
    [self setOverlayVisible:!_overlay_visible];
}
-(void)onDoubleTap:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:self.view];
    [self seekBy:point.x < self.view.bounds.size.width / 2 ? -_skip_seconds : _skip_seconds];
}

-(void)setOverlayVisible:(BOOL)visible {
    _overlay_visible = visible;
    _subtitle_bottom.constant = visible ? -72 : -28;
    [UIView animateWithDuration:0.2 animations:^{
        self.overlay.alpha = visible ? 1 : 0;
        [self.view layoutIfNeeded];
    }];
    if (visible) {
        [self scheduleHide];
    }
}
-(void)hideOverlay {
    if (_player.timeControlStatus != AVPlayerTimeControlStatusPaused && !_scrubbing) {
        [self setOverlayVisible:NO];
    }
}
-(void)scheduleHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOverlay) object:nil];
    [self performSelector:@selector(hideOverlay) withObject:nil afterDelay:3.5];
}

-(void)showMessage:(NSString*)title message:(NSString*)message closeAfter:(BOOL)close_after {
    if (self.presentedViewController) {
        return;
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:L(@"app.common.ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        if (close_after) {
            [self onClose];
        }
    }]];
    [_spinner stopAnimating];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

/* Метки для скачанной серии: ключ воспроизведения «release-source-position». MAL ID и метки берутся из кэша — работает без сети. */
static void LoadMarkersForLocalPlayback(AniLotPlayerViewController* controller, NSString* resume_key, NSString* title) {
    if (!AniLotSettingBool(AniLotSettingSkipButtonsKey, YES) && !AniLotSettingBool(AniLotSettingAutoSkipKey, NO)) {
        return;
    }
    NSArray<NSString*>* parts = [resume_key componentsSeparatedByString:@"-"];
    if (parts.count != 3 || title.length == 0) {
        return;
    }
    long long release_value = parts[0].longLongValue;
    long position = parts[2].integerValue;
    if (release_value <= 0) {
        return;
    }
    anixart::ReleaseID release_id{release_value};
    __weak AniLotPlayerViewController* weak_controller = controller;
    LoadAniSkipMarkers(release_id, position, title, ^(NSDictionary<NSString*, NSArray<NSNumber*>*>* found) {
        [weak_controller mergeMarkers:found overwrite:NO];
    });
}

#pragma mark - PlayerController

@interface PlayerController ()
@property(nonatomic, weak) AniLotPlayerViewController* player_view_controller;
@property(nonatomic, strong) AniLotPlayerViewController* pip_holder;
@end

@implementation PlayerController

-(instancetype)init {
    self = [super init];
    return self;
}

-(AniLotPlayerViewController*)makePlayerWithTitle:(NSString*)title resumeKey:(NSString*)resume_key {
    AniLotPlayerViewController* controller = [AniLotPlayerViewController new];
    controller.video_title = title;
    controller.resume_key = resume_key;
    controller.skip_seconds = DefaultSkipSeconds();
    controller.playlist = _pending_playlist;
    _pending_playlist = nil;
    _player_view_controller = controller;
    
    // Картинка в картинке: при старте закрываем полноэкранный плеер, но держим его в памяти
    __weak PlayerController* weak_self = self;
    controller.pip_will_start = ^(AniLotPlayerViewController* vc) {
        weak_self.pip_holder = vc;
        [vc dismissViewControllerAnimated:YES completion:nil];
    };
    controller.pip_restore = ^(AniLotPlayerViewController* vc, void (^completion)(BOOL restored)) {
        [TopViewController() presentViewController:vc animated:YES completion:^{
            weak_self.pip_holder = nil;
            completion(YES);
        }];
    };
    controller.pip_did_stop = ^(AniLotPlayerViewController* vc) {
        if (vc.view.window == nil && weak_self.pip_holder == vc) {
            [vc stopPlayback];
            weak_self.pip_holder = nil;
        }
    };
    controller.on_finished = ^(AniLotPlayerViewController* vc) {
        [weak_self playNextEpisodeInController:vc];
    };
    return controller;
}

-(void)showViewController:(UIViewController*)view_controller {
    [TopViewController() presentViewController:view_controller animated:NO completion:nil];
}

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler {
    [self playWithReleaseID:release_id sourceID:source_id position:position title:nil autoShow:auto_show completion:completion_handler];
}

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler {
    NSString* external = AniLotExternalPlayerID();
    BOOL use_external = ![external isEqualToString:@"internal"];
    NSString* resume_key = [NSString stringWithFormat:@"%lld-%lld-%ld", (long long)static_cast<int64_t>(release_id), (long long)static_cast<int64_t>(source_id), position];
    
    AniLotPlayerViewController* controller = nil;
    if (use_external) {
        _pending_playlist = nil;
    } else {
        controller = [self makePlayerWithTitle:title resumeKey:resume_key];
        controller.ctx_release_id = (long long)static_cast<int64_t>(release_id);
        controller.ctx_source_id = (long long)static_cast<int64_t>(source_id);
        controller.ctx_position = position;
    }
    if (controller && auto_show) {
        [self showViewController:controller];
    }
    [self loadReleaseID:release_id sourceID:source_id position:position title:title controller:controller external:external closeOnError:YES completion:completion_handler];
}

/* Получает ссылки на потоки и запускает серию в плеере (или во внешнем плеере, если controller == nil) */
-(void)loadReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title controller:(AniLotPlayerViewController*)controller external:(NSString*)external closeOnError:(BOOL)close_on_error completion:(void(^)(BOOL errored))completion_handler {
    BOOL use_external = (controller == nil);
    
    NSMutableDictionary* markers = [NSMutableDictionary new];
    if (controller && (AniLotSettingBool(AniLotSettingSkipButtonsKey, YES) || AniLotSettingBool(AniLotSettingAutoSkipKey, NO))) {
        __weak AniLotPlayerViewController* weak_controller = controller;
        LoadAniSkipMarkers(release_id, position, title, ^(NSDictionary<NSString*, NSArray<NSNumber*>*>* found) {
            // защита от гонки: метки относятся к серии, которая сейчас открыта
            if (weak_controller.ctx_position == position) {
                [weak_controller mergeMarkers:found overwrite:NO];
            }
        });
    }
    NSMutableArray<AniLotSubtitleTrack*>* subtitles = [NSMutableArray new];
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), markers, subtitles, ^(NSDictionary<NSString*, NSURL*>* urls, NSString* detail) {
        BOOL errored = (urls == nil);
        if (completion_handler) {
            completion_handler(errored);
        }
        NSString* error_message = [NSLocalizedString(@"app.player.stream_not_found_error.message", "") stringByAppendingFormat:@"\n\n%@", detail ?: @""];
        if (use_external) {
            if (errored) {
                ShowTopAlert(NSLocalizedString(@"app.player.stream_not_found_error.title", ""), error_message);
            } else {
                OpenInExternalPlayer(external, urls[ChooseQualityName(urls, PreferredQuality())]);
            }
            return;
        }
        if (controller.ctx_position != position) {
            return; // пользователь уже перешёл на другую серию
        }
        if (errored) {
            [controller showMessage:NSLocalizedString(@"app.player.stream_not_found_error.title", "") message:error_message closeAfter:close_on_error];
            return;
        }
        [controller mergeMarkers:markers overwrite:YES];
        [controller configureSubtitles:subtitles];
        [controller configureWithQualities:urls preferred:(controller.current_quality.length ? controller.current_quality : PreferredQuality())];
    });
}

/* «Автоматически следующая серия»: серия закончилась — запускаем следующую из списка источника */
-(void)playNextEpisodeInController:(AniLotPlayerViewController*)controller {
    NSDictionary* next = nil;
    NSArray<NSDictionary*>* list = controller.playlist;
    for (NSUInteger i = 0; i + 1 < list.count; i++) {
        if ([list[i][@"position"] longValue] == controller.ctx_position) {
            next = list[i + 1];
            break;
        }
    }
    if (!next) {
        return; // последняя серия (или список неизвестен)
    }
    long position = [next[@"position"] longValue];
    NSString* title = next[@"title"];
    anixart::ReleaseID release_id{controller.ctx_release_id};
    anixart::EpisodeSourceID source_id{controller.ctx_source_id};
    NSString* resume_key = [NSString stringWithFormat:@"%lld-%lld-%ld", controller.ctx_release_id, controller.ctx_source_id, position];
    
    controller.ctx_position = position;
    [controller prepareForNextEpisodeWithTitle:title resumeKey:resume_key];
    long long release_value = controller.ctx_release_id, source_value = controller.ctx_source_id;
    
    // Сначала убеждаемся, что для следующей серии удалось получить рабочую ссылку.
    // Не отмечаем её просмотренной, если поток не найден или пользователь уже выбрал другую серию.
    [self loadReleaseID:release_id sourceID:source_id position:position title:title controller:controller external:@"internal" closeOnError:NO completion:^(BOOL errored) {
        if (errored || controller.ctx_position != position) {
            return;
        }
        [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
            api->episodes().add_watched_episode(release_id, source_id, static_cast<int32_t>(position));
            return NO;
        } completion:^(BOOL update_errored) {
            if (update_errored) {
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AniLotEpisodeWatchedNotification object:nil userInfo:@{
                @"release_id": @(release_value),
                @"source_id": @(source_value),
                @"position": @(position)
            }];
        }];
    }];
}

-(void)playWithURL:(NSURL*)url {
    _pending_playlist = nil;
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:nil resumeKey:nil];
    [self showViewController:controller];
    [controller startWithURL:url];
}

-(void)playLocalURL:(NSURL*)url title:(NSString*)title {
    [self playLocalURL:url title:title resumeKey:nil];
}

-(void)playLocalURL:(NSURL*)url title:(NSString*)title resumeKey:(NSString*)resume_key {
    _pending_playlist = nil;
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:title resumeKey:resume_key];
    if (!url || ![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [TopViewController() presentViewController:controller animated:NO completion:^{
            [controller showMessage:L(@"app.downloads.file_missing.title", @"Файл не найден") message:L(@"app.downloads.file_missing.message", @"Скачанный файл недоступен. Удалите загрузку в Настройки → Загрузки и скачайте серию заново.") closeAfter:YES];
        }];
        return;
    }
    [self showViewController:controller];
    [controller startWithURL:url];
    LoadMarkersForLocalPlayback(controller, resume_key, title);
}

-(UIViewController*)getPlayer {
    return _player_view_controller;
}

+(instancetype)sharedInstance {
    static PlayerController* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PlayerController new];
    });
    return sharedInstance;
}

@end

#pragma mark - Загрузки

static NSString* RelativeToHome(NSString* absolute_path) {
    NSString* home = [NSHomeDirectory() stringByResolvingSymlinksInPath];
    NSString* full = [absolute_path stringByResolvingSymlinksInPath];
    if ([full hasPrefix:home]) {
        NSString* relative = [full substringFromIndex:home.length];
        while ([relative hasPrefix:@"/"]) {
            relative = [relative substringFromIndex:1];
        }
        return relative;
    }
    return absolute_path;
}

static NSURL* ResolveRelativeURL(NSString* reference, NSURL* base) {
    return [NSURL URLWithString:reference relativeToURL:base].absoluteURL;
}

@implementation DownloadItem

-(NSURL*)localURL {
    if (_relative_path.length == 0) {
        return nil;
    }
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableArray<NSString*>* candidates = [NSMutableArray new];
    if ([_relative_path hasPrefix:@"/"]) {
        [candidates addObject:_relative_path];
    }
    [candidates addObject:[NSHomeDirectory() stringByAppendingPathComponent:_relative_path]];
    for (NSString* path in candidates) {
        if ([fm fileExistsAtPath:path]) {
            return [NSURL fileURLWithPath:path];
        }
    }
    return nil;
}

-(NSDictionary*)toDictionary {
    return @{
        @"id": _identifier ?: @"",
        @"title": _title ?: @"",
        @"release_title": _release_title ?: @"",
        @"error": _error_text ?: @"",
        @"release_id": @(_release_id),
        @"source_id": @(_source_id),
        @"position": @(_position),
        @"state": @(_state),
        @"path": _relative_path ?: @"",
        @"hls": @(_is_hls)
    };
}

+(instancetype)fromDictionary:(NSDictionary*)dict {
    DownloadItem* item = [DownloadItem new];
    item.identifier = dict[@"id"];
    item.title = dict[@"title"];
    item.release_title = dict[@"release_title"];
    item.error_text = dict[@"error"];
    item.release_id = [dict[@"release_id"] longLongValue];
    item.source_id = [dict[@"source_id"] longLongValue];
    item.position = [dict[@"position"] longValue];
    item.state = (DownloadState)[dict[@"state"] integerValue];
    item.relative_path = dict[@"path"];
    item.is_hls = [dict[@"hls"] boolValue];
    item.progress = item.state == DownloadStateCompleted ? 1.0 : 0.0;
    return item;
}

@end

@interface DownloadManager () <AVAssetDownloadDelegate, NSURLSessionDownloadDelegate>
@property(nonatomic, strong) NSMutableArray<DownloadItem*>* mutable_items;
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSURLSessionTask*>* tasks;
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSURL*>* source_urls;
@property(nonatomic, strong) NSMutableSet<NSString*>* fallback_started;
@property(nonatomic, strong) AVAssetDownloadURLSession* hls_session;
@property(nonatomic, strong) NSURLSession* file_session;
@end

@implementation DownloadManager

+(instancetype)sharedInstance {
    static DownloadManager* shared = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [DownloadManager new];
    });
    return shared;
}

-(instancetype)init {
    self = [super init];
    
    _mutable_items = [NSMutableArray new];
    _tasks = [NSMutableDictionary new];
    _source_urls = [NSMutableDictionary new];
    _fallback_started = [NSMutableSet new];
    NSArray* saved = [[NSUserDefaults standardUserDefaults] arrayForKey:@"anilot_downloads"];
    for (NSDictionary* dict in saved) {
        DownloadItem* item = [DownloadItem fromDictionary:dict];
        if (item.identifier.length) {
            [_mutable_items addObject:item];
        }
    }
    
    NSURLSessionConfiguration* hls_conf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"org.anilot.hls-downloads"];
    _hls_session = [AVAssetDownloadURLSession sessionWithConfiguration:hls_conf assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _file_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // Незавершённые загрузки: подцепляем живые задачи фоновой сессии, остальные помечаем как прерванные
    [_hls_session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask*>* tasks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSURLSessionTask* task in tasks) {
                if (task.taskDescription) {
                    self->_tasks[task.taskDescription] = task;
                }
            }
            for (DownloadItem* item in self->_mutable_items) {
                if ((item.state == DownloadStateDownloading || item.state == DownloadStateQueued) && !self->_tasks[item.identifier]) {
                    item.state = DownloadStateFailed;
                    item.error_text = @"Загрузка была прервана";
                }
            }
            [self saveAndNotify];
        });
    }];
    
    return self;
}

-(NSArray<DownloadItem*>*)items {
    return [_mutable_items copy];
}

-(DownloadItem*)itemWithIdentifier:(NSString*)identifier {
    for (DownloadItem* item in _mutable_items) {
        if ([item.identifier isEqualToString:identifier]) {
            return item;
        }
    }
    return nil;
}

+(NSString*)identifierForRelease:(long long)release_id source:(long long)source_id position:(long)position {
    return [NSString stringWithFormat:@"%lld-%lld-%ld", release_id, source_id, position];
}

-(DownloadItem*)itemForReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position {
    return [self itemWithIdentifier:[DownloadManager identifierForRelease:static_cast<int64_t>(release_id) source:static_cast<int64_t>(source_id) position:position]];
}

-(void)saveAndNotify {
    NSMutableArray* array = [NSMutableArray new];
    for (DownloadItem* item in _mutable_items) {
        [array addObject:[item toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"anilot_downloads"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerDidUpdateNotification object:self];
}

-(void)fetchReleaseTitleForItem:(DownloadItem*)item releaseID:(anixart::ReleaseID)release_id {
    if (item.release_title.length) {
        return;
    }
    LibanixartApi* api_proxy = [LibanixartApi sharedInstance];
    __block NSString* name = nil;
    [api_proxy asyncCall:^BOOL(anixart::Api* api) {
        auto release = api->releases().get_release(release_id);
        std::string title = release->title_ru.empty() ? release->title_original : release->title_ru;
        name = TO_NSSTRING(title);
        return NO;
    } completion:^(BOOL errored) {
        if (!errored && name.length) {
            item.release_title = name;
            [self saveAndNotify];
        }
    }];
}

-(void)downloadReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title completion:(void(^)(BOOL errored))completion {
    long long release_value = static_cast<int64_t>(release_id);
    long long source_value = static_cast<int64_t>(source_id);
    NSString* identifier = [DownloadManager identifierForRelease:release_value source:source_value position:position];
    
    DownloadItem* item = [self itemWithIdentifier:identifier];
    if (item && (item.state == DownloadStateCompleted || item.state == DownloadStateDownloading || item.state == DownloadStateQueued)) {
        if (completion) completion(NO);
        return;
    }
    if (!item) {
        item = [DownloadItem new];
        item.identifier = identifier;
        item.release_id = release_value;
        item.source_id = source_value;
        item.position = position;
        [_mutable_items addObject:item];
    }
    item.title = title;
    item.state = DownloadStateQueued;
    item.progress = 0;
    item.cancelled = NO;
    item.error_text = nil;
    [_fallback_started removeObject:identifier];
    [self saveAndNotify];
    [self fetchReleaseTitleForItem:item releaseID:release_id];
    
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), nil, nil, ^(NSDictionary<NSString*, NSURL*>* urls, NSString* detail) {
        if (!urls) {
            item.state = DownloadStateFailed;
            item.error_text = [@"Не найден источник серии\n" stringByAppendingString:detail ?: @""];
            [self saveAndNotify];
            if (completion) completion(YES);
            return;
        }
        NSURL* url = urls[ChooseQualityName(urls, PreferredQuality())];
        [self startTaskForItem:item url:url];
        if (completion) completion(NO);
    });
}

-(void)startTaskForItem:(DownloadItem*)item url:(NSURL*)url {
    _source_urls[item.identifier] = url;
    BOOL is_hls = [url.absoluteString.lowercaseString containsString:@".m3u8"];
    item.is_hls = is_hls;
    
    if (is_hls) {
        // Системная загрузка HLS; если не стартует или падает — переходим на собственный загрузчик
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSURLSessionTask* task = [_hls_session assetDownloadTaskWithURLAsset:asset assetTitle:item.title ?: @"AniLot" assetArtworkData:nil options:nil];
        if (!task) {
            [self startFallbackForItem:item url:url];
            return;
        }
        task.taskDescription = item.identifier;
        _tasks[item.identifier] = task;
        item.state = DownloadStateDownloading;
        [self saveAndNotify];
        [task resume];
        
        NSString* identifier = item.identifier;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DownloadItem* current = [self itemWithIdentifier:identifier];
            if (current && current.state == DownloadStateDownloading && current.progress <= 0.0001 && ![self->_fallback_started containsObject:identifier]) {
                NSURLSessionTask* stuck = self->_tasks[identifier];
                [self startFallbackForItem:current url:url];
                [stuck cancel];
            }
        });
        return;
    }
    
    NSURLSessionTask* task = [_file_session downloadTaskWithRequest:RequestForStream(url)];
    task.taskDescription = item.identifier;
    _tasks[item.identifier] = task;
    item.state = DownloadStateDownloading;
    [self saveAndNotify];
    [task resume];
}

-(void)deleteItem:(DownloadItem*)item {
    item.cancelled = YES;
    NSURLSessionTask* task = _tasks[item.identifier];
    [_tasks removeObjectForKey:item.identifier];
    [task cancel];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* local = item.localURL;
    if (local) {
        if ([local.lastPathComponent isEqualToString:@"index.m3u8"]) {
            [fm removeItemAtURL:[local URLByDeletingLastPathComponent] error:nil];
        } else {
            [fm removeItemAtURL:local error:nil];
        }
    }
    NSURL* documents = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    [fm removeItemAtURL:[[documents URLByAppendingPathComponent:@"Downloads" isDirectory:YES] URLByAppendingPathComponent:item.identifier isDirectory:YES] error:nil];
    [_mutable_items removeObject:item];
    [self saveAndNotify];
}

#pragma mark Собственный загрузчик HLS (запасной путь)

-(void)startFallbackForItem:(DownloadItem*)item url:(NSURL*)url {
    if ([_fallback_started containsObject:item.identifier]) {
        return;
    }
    [_fallback_started addObject:item.identifier];
    item.state = DownloadStateDownloading;
    item.progress = 0;
    item.error_text = nil;
    [self saveAndNotify];
    
    UIBackgroundTaskIdentifier background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSString* error = nil;
        NSString* relative = [self fallbackDownloadURL:url item:item error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!item.cancelled) {
                if (relative) {
                    item.relative_path = relative;
                    item.state = DownloadStateCompleted;
                    item.progress = 1.0;
                    item.error_text = nil;
                } else {
                    item.state = DownloadStateFailed;
                    item.error_text = error ?: @"Не удалось скачать серию";
                }
                [self saveAndNotify];
            }
            if (background_task != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:background_task];
            }
        });
    });
}

-(void)fetchURL:(NSURL*)url toFile:(NSURL*)destination session:(NSURLSession*)session attempt:(int)attempt completion:(void(^)(BOOL ok))completion {
    [[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 200;
        if (data && !error && status < 400 && [data writeToURL:destination atomically:YES]) {
            completion(YES);
            return;
        }
        if (attempt < 2) {
            [self fetchURL:url toFile:destination session:session attempt:attempt + 1 completion:completion];
            return;
        }
        completion(NO);
    }] resume];
}

-(NSString*)fallbackDownloadURL:(NSURL*)url item:(DownloadItem*)item error:(NSString**)error {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* documents = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL* directory = [[documents URLByAppendingPathComponent:@"Downloads" isDirectory:YES] URLByAppendingPathComponent:item.identifier isDirectory:YES];
    [fm removeItemAtURL:directory error:nil];
    [fm createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSInteger status = 0;
    NSString* net_error = nil;
    NSData* data = SyncRequest(url, @{}, &status, &net_error);
    NSString* text = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    if (![text hasPrefix:@"#EXTM3U"]) {
        *error = [NSString stringWithFormat:@"Плейлист недоступен (HTTP %ld %@)", (long)status, net_error ?: @""];
        return nil;
    }
    
    NSURL* base = url;
    if ([text containsString:@"#EXT-X-STREAM-INF"]) {
        NSArray<NSString*>* lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        long long best_bandwidth = -1;
        NSString* best_uri = nil;
        for (NSUInteger i = 0; i < lines.count; i++) {
            NSString* line = [lines[i] stringByTrimmingCharactersInSet:whitespace];
            if (![line hasPrefix:@"#EXT-X-STREAM-INF"]) {
                continue;
            }
            long long bandwidth = FirstMatch(@"BANDWIDTH=(\\d+)", line).longLongValue;
            for (NSUInteger j = i + 1; j < lines.count; j++) {
                NSString* next = [lines[j] stringByTrimmingCharactersInSet:whitespace];
                if (next.length == 0 || [next hasPrefix:@"#"]) {
                    continue;
                }
                if (bandwidth > best_bandwidth) {
                    best_bandwidth = bandwidth;
                    best_uri = next;
                }
                break;
            }
        }
        if (!best_uri) {
            *error = @"В мастер-плейлисте нет потоков";
            return nil;
        }
        base = ResolveRelativeURL(best_uri, url);
        data = SyncRequest(base, @{}, &status, &net_error);
        text = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        if (![text hasPrefix:@"#EXTM3U"]) {
            *error = [NSString stringWithFormat:@"Плейлист потока недоступен (HTTP %ld %@)", (long)status, net_error ?: @""];
            return nil;
        }
    }
    
    NSMutableArray<NSString*>* output = [NSMutableArray new];
    NSMutableArray<NSArray*>* resources = [NSMutableArray new];
    int segment_index = 0, aux_index = 0;
    for (NSString* raw in [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        NSString* line = [raw stringByTrimmingCharactersInSet:whitespace];
        if (line.length == 0) {
            continue;
        }
        if ([line hasPrefix:@"#"]) {
            if ([line hasPrefix:@"#EXT-X-KEY"] || [line hasPrefix:@"#EXT-X-MAP"]) {
                NSString* uri = FirstMatch(@"URI=\"([^\"]+)\"", line);
                if (uri) {
                    NSString* extension = [line hasPrefix:@"#EXT-X-KEY"] ? @"key" : @"mp4";
                    NSString* local = [NSString stringWithFormat:@"aux_%d.%@", aux_index++, extension];
                    [resources addObject:@[ResolveRelativeURL(uri, base), local]];
                    line = [line stringByReplacingOccurrencesOfString:uri withString:local];
                }
            }
            [output addObject:line];
        } else {
            NSURL* remote = ResolveRelativeURL(line, base);
            NSString* extension = remote.pathExtension;
            if (extension.length == 0 || extension.length > 5) {
                extension = @"ts";
            }
            NSString* local = [NSString stringWithFormat:@"seg_%05d.%@", segment_index++, extension];
            [resources addObject:@[remote, local]];
            [output addObject:local];
        }
    }
    if (segment_index == 0) {
        *error = @"В плейлисте нет сегментов";
        return nil;
    }
    
    NSUInteger total = resources.count;
    __block NSUInteger done = 0;
    __block BOOL failed = NO;
    dispatch_semaphore_t slots = dispatch_semaphore_create(4);
    dispatch_group_t group = dispatch_group_create();
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    for (NSArray* resource in resources) {
        dispatch_semaphore_wait(slots, DISPATCH_TIME_FOREVER);
        if (item.cancelled || failed) {
            dispatch_semaphore_signal(slots);
            break;
        }
        dispatch_group_enter(group);
        NSURL* destination = [directory URLByAppendingPathComponent:resource[1]];
        [self fetchURL:resource[0] toFile:destination session:session attempt:0 completion:^(BOOL ok) {
            if (!ok) {
                failed = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                done++;
                item.progress = (double)done / (double)total;
                [[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerDidUpdateNotification object:self];
            });
            dispatch_semaphore_signal(slots);
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [session finishTasksAndInvalidate];
    
    if (item.cancelled) {
        [fm removeItemAtURL:directory error:nil];
        return nil;
    }
    if (failed) {
        *error = @"Не удалось скачать часть сегментов";
        return nil;
    }
    if (![output containsObject:@"#EXT-X-ENDLIST"]) {
        [output addObject:@"#EXT-X-ENDLIST"];
    }
    NSURL* index = [directory URLByAppendingPathComponent:@"index.m3u8"];
    if (![[output componentsJoinedByString:@"\n"] writeToURL:index atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        *error = @"Не удалось сохранить плейлист";
        return nil;
    }
    return RelativeToHome(index.path);
}

#pragma mark HLS (AVAssetDownloadDelegate)

-(void)URLSession:(NSURLSession*)session assetDownloadTask:(AVAssetDownloadTask*)task didLoadTimeRange:(CMTimeRange)time_range totalTimeRangesLoaded:(NSArray<NSValue*>*)loaded timeRangeExpectedToLoad:(CMTimeRange)expected {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item || [_fallback_started containsObject:item.identifier]) {
        return;
    }
    double done = 0;
    for (NSValue* value in loaded) {
        done += CMTimeGetSeconds(value.CMTimeRangeValue.duration);
    }
    double total = CMTimeGetSeconds(expected.duration);
    item.progress = total > 0 ? MIN(1.0, done / total) : 0.001;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerDidUpdateNotification object:self];
}

-(void)URLSession:(NSURLSession*)session assetDownloadTask:(AVAssetDownloadTask*)task didFinishDownloadingToURL:(NSURL*)location {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item || [_fallback_started containsObject:item.identifier]) {
        return;
    }
    // храним путь относительно домашней папки приложения (абсолютный путь меняется между запусками)
    item.relative_path = RelativeToHome(location.path);
    item.progress = 1.0;
}

#pragma mark Обычные файлы (NSURLSessionDownloadDelegate)

-(void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)task didWriteData:(int64_t)bytes totalBytesWritten:(int64_t)written totalBytesExpectedToWrite:(int64_t)expected {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item) {
        return;
    }
    item.progress = expected > 0 ? (double)written / (double)expected : 0.001;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerDidUpdateNotification object:self];
}

-(void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)task didFinishDownloadingToURL:(NSURL*)location {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item) {
        return;
    }
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* documents = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL* directory = [documents URLByAppendingPathComponent:@"Downloads" isDirectory:YES];
    [fm createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSURL* destination = [directory URLByAppendingPathComponent:[item.identifier stringByAppendingString:@".mp4"]];
    [fm removeItemAtURL:destination error:nil];
    NSError* error = nil;
    if ([fm moveItemAtURL:location toURL:destination error:&error]) {
        item.relative_path = RelativeToHome(destination.path);
        item.progress = 1.0;
    } else {
        item.state = DownloadStateFailed;
        item.error_text = error.localizedDescription;
    }
}

#pragma mark Завершение

-(void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task didCompleteWithError:(NSError*)error {
    NSString* identifier = task.taskDescription;
    DownloadItem* item = [self itemWithIdentifier:identifier];
    if (!item) {
        return;
    }
    [_tasks removeObjectForKey:identifier];
    if ([_fallback_started containsObject:identifier]) {
        return; // этим элементом уже управляет собственный загрузчик
    }
    if (error) {
        NSURL* source_url = _source_urls[identifier];
        if (item.is_hls && source_url && error.code != NSURLErrorCancelled) {
            item.error_text = error.localizedDescription;
            [self startFallbackForItem:item url:source_url];
            return;
        }
        item.state = DownloadStateFailed;
        item.error_text = error.localizedDescription;
    } else if (item.state != DownloadStateFailed && item.relative_path.length > 0) {
        item.state = DownloadStateCompleted;
        item.progress = 1.0;
        item.error_text = nil;
    } else if (item.state != DownloadStateFailed) {
        item.state = DownloadStateFailed;
        item.error_text = @"Файл не был сохранён";
    }
    [self saveAndNotify];
}

@end
