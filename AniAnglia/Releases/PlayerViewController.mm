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
#import "PlayerViewController.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

NSString* const DownloadManagerDidUpdateNotification = @"AniLotDownloadManagerDidUpdate";

NSString* const AniLotSettingResumeKey = @"anilot_resume_enabled";
NSString* const AniLotSettingSkipButtonsKey = @"anilot_skip_buttons";
NSString* const AniLotSettingAutoSkipKey = @"anilot_auto_skip";
static NSString* const kExternalPlayerKey = @"anilot_external_player";
static NSString* const kPositionsKey = @"anilot_positions";

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
static NSDictionary<NSString*, NSURL*>* ResolveIframeStreams(NSString* target, NSMutableString* detail) {
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

/* Определяет конечный адрес после редиректов, не скачивая тело файла */
@interface AniLotRedirectResolver : NSObject <NSURLSessionDataDelegate>
@property(nonatomic, strong) NSURL* final_url;
@property(nonatomic) NSInteger status;
@end
@implementation AniLotRedirectResolver
-(void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask*)task didReceiveResponse:(NSURLResponse*)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completion_handler {
    _final_url = response.URL;
    _status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
    completion_handler(NSURLSessionResponseCancel);
}
@end

static NSURL* ResolveFinalURL(NSURL* url, NSDictionary<NSString*, NSString*>* headers, NSInteger* status) {
    AniLotRedirectResolver* resolver = [AniLotRedirectResolver new];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:resolver delegateQueue:nil];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15;
    for (NSString* key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC)));
    [session invalidateAndCancel];
    if (status) *status = resolver.status;
    return resolver.final_url;
}

#pragma mark - Sibnet

/* Парсер Sibnet внутри libanixart устарел: страница плеера теперь отдаёт путь /v/<hash>/<id>.mp4,
   который редиректит на CDN и требует Referer. Разбираем страницу сами. */
static NSDictionary<NSString*, NSURL*>* ResolveSibnetStreams(NSString* target, NSMutableString* detail) {
    NSString* video_id = FirstMatch(@"videoid=(\\d+)", target) ?: FirstMatch(@"/video(\\d+)", target) ?: FirstMatch(@"embed/(\\d+)", target) ?: FirstMatch(@"[?&]id=(\\d+)", target);
    [detail appendFormat:@"Sibnet: %@\n", target];
    if (!video_id) {
        [detail appendString:@"Не удалось определить id видео из ссылки\n"];
        return nil;
    }
    NSString* shell = [NSString stringWithFormat:@"https://video.sibnet.ru/shell.php?videoid=%@", video_id];
    NSString* user_agent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1";
    NSDictionary* page_headers = @{@"User-Agent": user_agent, @"Referer": @"https://video.sibnet.ru/", @"Accept": @"text/html,*/*"};
    NSInteger status = 0;
    NSString* error_text = nil;
    NSData* data = SyncRequest([NSURL URLWithString:shell], page_headers, &status, &error_text);
    [detail appendFormat:@"shell.php → HTTP %ld %@\n", (long)status, error_text ?: @""];
    NSString* html = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
    if (!html) {
        html = data ? [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding] : nil;
    }
    if (html.length == 0) {
        return nil;
    }
    html = [html stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSString* path = FirstMatch(@"src\\s*:\\s*[\"'](/v/[^\"']+?\\.mp4[^\"']*)[\"']", html) ?: FirstMatch(@"[\"'](/v/[^\"']+?\\.mp4[^\"']*)[\"']", html);
    NSString* absolute = nil;
    if (path) {
        absolute = [@"https://video.sibnet.ru" stringByAppendingString:path];
    } else {
        absolute = FirstMatch(@"[\"'](https?://[^\"']+?\\.mp4[^\"']*)[\"']", html);
    }
    if (!absolute) {
        NSString* compact = [[html componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@" "];
        [detail appendFormat:@"В странице нет ссылки на mp4 (%lu байт). Начало: %@\n", (unsigned long)html.length, [compact substringToIndex:MIN((NSUInteger)400, compact.length)]];
        return nil;
    }
    NSDictionary* media_headers = @{@"User-Agent": user_agent, @"Referer": shell};
    NSInteger final_status = 0;
    NSURL* final_url = ResolveFinalURL([NSURL URLWithString:absolute], media_headers, &final_status);
    [detail appendFormat:@"mp4 → %@ (HTTP %ld)\n", final_url.host ?: @"?", (long)final_status];
    if (!final_url || (final_status >= 400)) {
        return nil;
    }
    RememberStreamHeaders(final_url, media_headers);
    RememberStreamHeaders([NSURL URLWithString:absolute], media_headers);
    return @{@"720": final_url};
}

#pragma mark - AniSkip (метки опенингов и эндингов для любых источников)

static NSString* const kMalIdsKey = @"anilot_mal_ids";

static NSString* LookupMalID(anixart::ReleaseID release_id, NSString* title, NSString* alt_title) {
    NSString* cache_key = [NSString stringWithFormat:@"%lld", (long long)static_cast<int64_t>(release_id)];
    NSDictionary* cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMalIdsKey];
    if (cache[cache_key]) {
        return [cache[cache_key] description];
    }
    for (NSString* query in @[title ?: @"", alt_title ?: @""]) {
        if (query.length == 0) {
            continue;
        }
        NSString* encoded = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.jikan.moe/v4/anime?q=%@&limit=5&order_by=popularity", encoded]];
        NSInteger status = 0;
        NSData* data = url ? SyncGET(url, &status, nil) : nil;
        if (status != 200 || !data) {
            continue;
        }
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray* items = [json isKindOfClass:[NSDictionary class]] ? json[@"data"] : nil;
        NSDictionary* chosen = nil;
        for (NSDictionary* item in items) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSMutableArray<NSString*>* names = [NSMutableArray new];
            for (NSString* key in @[@"title", @"title_english", @"title_japanese"]) {
                if ([item[key] isKindOfClass:[NSString class]]) {
                    [names addObject:[item[key] lowercaseString]];
                }
            }
            for (NSDictionary* t in item[@"titles"]) {
                if ([t isKindOfClass:[NSDictionary class]] && [t[@"title"] isKindOfClass:[NSString class]]) {
                    [names addObject:[t[@"title"] lowercaseString]];
                }
            }
            if ([names containsObject:query.lowercaseString]) {
                chosen = item;
                break;
            }
        }
        if (!chosen && [items.firstObject isKindOfClass:[NSDictionary class]]) {
            chosen = items.firstObject;
        }
        id mal_id = chosen[@"mal_id"];
        if ([mal_id respondsToSelector:@selector(longLongValue)] && [mal_id longLongValue] > 0) {
            NSMutableDictionary* updated = [cache mutableCopy] ?: [NSMutableDictionary new];
            updated[cache_key] = [mal_id description];
            [[NSUserDefaults standardUserDefaults] setObject:updated forKey:kMalIdsKey];
            return [mal_id description];
        }
    }
    return nil;
}

static NSDictionary<NSString*, NSArray<NSNumber*>*>* FetchAniSkipMarkers(NSString* mal_id, long episode) {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.aniskip.com/v2/skip-times/%@/%ld?types=op&types=ed&types=mixed-op&types=mixed-ed&episodeLength=0", mal_id, episode]];
    NSInteger status = 0;
    NSData* data = url ? SyncGET(url, &status, nil) : nil;
    if (status != 200 || !data) {
        return nil;
    }
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray* results = [json isKindOfClass:[NSDictionary class]] ? json[@"results"] : nil;
    NSMutableDictionary<NSString*, NSArray<NSNumber*>*>* markers = [NSMutableDictionary new];
    for (NSDictionary* item in results) {
        if (![item isKindOfClass:[NSDictionary class]] || ![item[@"interval"] isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString* type = [item[@"skipType"] description];
        NSString* name = [type hasSuffix:@"op"] ? @"opening" : ([type hasSuffix:@"ed"] ? @"ending" : nil);
        double start = [item[@"interval"][@"startTime"] doubleValue];
        double end = [item[@"interval"][@"endTime"] doubleValue];
        if (name && end > start && !markers[name]) {
            markers[name] = @[@(start), @(end)];
        }
    }
    return markers.count ? markers : nil;
}

static void LoadAniSkipMarkers(anixart::ReleaseID release_id, long position, void (^completion)(NSDictionary<NSString*, NSArray<NSNumber*>*>* markers)) {
    __block NSString* title = nil;
    __block NSString* alt_title = nil;
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        auto release = api->releases().get_release(release_id);
        if (release) {
            title = TO_NSSTRING(release->title_original);
            alt_title = TO_NSSTRING(release->title_alt);
        }
        return NO;
    } completion:^(BOOL errored) {
        if (errored || (title.length == 0 && alt_title.length == 0)) {
            return;
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            NSString* mal_id = LookupMalID(release_id, title, alt_title);
            NSDictionary* markers = mal_id ? FetchAniSkipMarkers(mal_id, position) : nil;
            if (markers.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(markers);
                });
            }
        });
    }];
}

static void ResolveStreams(anixart::ReleaseID release_id, anixart::EpisodeSourceID source_id, int32_t position, NSMutableDictionary* markers, void (^completion)(NSDictionary<NSString*, NSURL*>* urls, NSString* detail)) {
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
                result = ResolveIframeStreams(target, detail);
                if (!result.count) {
                    result = ResolveLibriaStreams(target, detail, markers);
                }
            } else {
                result = ResolveLibriaStreams(target, detail, markers);
                if (!result.count) {
                    result = ResolveIframeStreams(target, detail);
                }
            }
            if (result.count) {
                return NO;
            }
        }
        if ([lower containsString:@"sibnet"]) {
            result = ResolveSibnetStreams(target, detail);
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

-(void)mergeMarkers:(NSDictionary<NSString*, NSArray<NSNumber*>*>*)markers overwrite:(BOOL)overwrite;
-(void)startWithURL:(NSURL*)url;
-(void)configureWithQualities:(NSDictionary<NSString*, NSURL*>*)urls preferred:(NSString*)preferred;
-(void)showMessage:(NSString*)title message:(NSString*)message closeAfter:(BOOL)close_after;
-(void)stopPlayback;
@end

@interface AniLotPlayerViewController () <AVPictureInPictureControllerDelegate> {
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
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:_pip_button.leadingAnchor constant:-8],
        
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
        
        [_skip_button.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [_skip_button.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-68],
        [_skip_button.heightAnchor constraintEqualToConstant:36],
        
        [_toast_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_toast_label.topAnchor constraintEqualToAnchor:_close_button.bottomAnchor constant:10],
        [_toast_label.heightAnchor constraintEqualToConstant:28],
        [_toast_label.widthAnchor constraintGreaterThanOrEqualToConstant:120]
    ]];
    
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
    }];
    _poll_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer* timer) {
        [weak_self updateUI];
    }];
    [_player playImmediatelyAtRate:_rate];
    [self updateUI];
    [self scheduleHide];
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
    
    // пропуск опенинга / эндинга
    BOOL show_buttons = AniLotSettingBool(AniLotSettingSkipButtonsKey, YES);
    BOOL auto_skip = AniLotSettingBool(AniLotSettingAutoSkipKey, NO);
    NSString* title = nil;
    NSString* marker_name = nil;
    double target = 0;
    for (NSString* name in @[@"opening", @"ending"]) {
        NSArray<NSNumber*>* range = _markers[name];
        if (range.count == 2 && range[1].doubleValue > range[0].doubleValue && current >= range[0].doubleValue - 0.5 && current < range[1].doubleValue - 1) {
            marker_name = name;
            target = range[1].doubleValue;
            title = [name isEqualToString:@"opening"] ? L(@"app.player.skip_opening", @"Пропустить опенинг") : L(@"app.player.skip_ending", @"Пропустить эндинг");
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
    [_player seekToTime:time];
    if (!was_paused) {
        [_player playImmediatelyAtRate:_rate];
    }
    [self rebuildMenus];
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
    [UIView animateWithDuration:0.2 animations:^{
        self.overlay.alpha = visible ? 1 : 0;
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
    
    AniLotPlayerViewController* controller = use_external ? nil : [self makePlayerWithTitle:title resumeKey:resume_key];
    if (controller && auto_show) {
        [self showViewController:controller];
    }
    
    NSMutableDictionary* markers = [NSMutableDictionary new];
    if (controller && (AniLotSettingBool(AniLotSettingSkipButtonsKey, YES) || AniLotSettingBool(AniLotSettingAutoSkipKey, NO))) {
        __weak AniLotPlayerViewController* weak_controller = controller;
        LoadAniSkipMarkers(release_id, position, ^(NSDictionary<NSString*, NSArray<NSNumber*>*>* found) {
            [weak_controller mergeMarkers:found overwrite:NO];
        });
    }
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), markers, ^(NSDictionary<NSString*, NSURL*>* urls, NSString* detail) {
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
        if (errored) {
            [controller showMessage:NSLocalizedString(@"app.player.stream_not_found_error.title", "") message:error_message closeAfter:YES];
            return;
        }
        [controller mergeMarkers:markers overwrite:YES];
        [controller configureWithQualities:urls preferred:PreferredQuality()];
    });
}

-(void)playWithURL:(NSURL*)url {
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:nil resumeKey:nil];
    [self showViewController:controller];
    [controller startWithURL:url];
}

-(void)playLocalURL:(NSURL*)url title:(NSString*)title {
    [self playLocalURL:url title:title resumeKey:nil];
}

-(void)playLocalURL:(NSURL*)url title:(NSString*)title resumeKey:(NSString*)resume_key {
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:title resumeKey:resume_key];
    if (!url || ![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [TopViewController() presentViewController:controller animated:NO completion:^{
            [controller showMessage:L(@"app.downloads.file_missing.title", @"Файл не найден") message:L(@"app.downloads.file_missing.message", @"Скачанный файл недоступен. Удалите загрузку в Настройки → Загрузки и скачайте серию заново.") closeAfter:YES];
        }];
        return;
    }
    [self showViewController:controller];
    [controller startWithURL:url];
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
    
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), nil, ^(NSDictionary<NSString*, NSURL*>* urls, NSString* detail) {
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
