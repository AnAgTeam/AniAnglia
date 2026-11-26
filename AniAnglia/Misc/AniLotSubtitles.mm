//
//  AniLotSubtitles.mm
//  AniLot
//
//  Субтитры для собственного плеера: парсеры WebVTT / SRT / ASS и поиск ссылок на субтитры.
//

#import "AniLotSubtitles.h"
#include <algorithm>
#include <cctype>

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

static NSString* const kBrowserUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1";

#pragma mark - Модель

@implementation AniLotSubtitleCue
@end

@implementation AniLotSubtitleTrack

-(NSString*)textAtTime:(double)time {
    NSArray<AniLotSubtitleCue*>* cues = _cues;
    if (cues.count == 0) {
        return nil;
    }
    // бинарный поиск последней реплики, начавшейся не позже time
    NSInteger low = 0;
    NSInteger high = (NSInteger)cues.count - 1;
    NSInteger found = -1;
    while (low <= high) {
        NSInteger mid = (low + high) / 2;
        if (cues[(NSUInteger)mid].start <= time) {
            found = mid;
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    if (found < 0) {
        return nil;
    }
    // реплики могут перекрываться — проверяем несколько предыдущих
    NSMutableArray<NSString*>* lines = [NSMutableArray new];
    for (NSInteger i = found; i >= 0 && i > found - 6; i--) {
        AniLotSubtitleCue* cue = cues[(NSUInteger)i];
        if (time >= cue.start && time < cue.end && cue.text.length) {
            [lines insertObject:cue.text atIndex:0];
        }
    }
    return lines.count ? [lines componentsJoinedByString:@"\n"] : nil;
}

-(void)loadWithCompletion:(void(^)(BOOL ok))completion {
    if (_cues != nil) {
        if (completion) completion(_cues.count > 0);
        return;
    }
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_url];
    request.timeoutInterval = 20;
    [request setValue:kBrowserUserAgent forHTTPHeaderField:@"User-Agent"];
    if (_url.host.length) {
        [request setValue:[NSString stringWithFormat:@"%@://%@/", _url.scheme ?: @"https", _url.host] forHTTPHeaderField:@"Referer"];
    }
    for (NSString* key in _headers) {
        [request setValue:_headers[key] forHTTPHeaderField:key];
    }
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
        NSArray<AniLotSubtitleCue*>* parsed = nil;
        if (!error && data.length && status >= 200 && status < 300) {
            NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!text) {
                text = [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding];
            }
            if (text) {
                parsed = AniLotParseSubtitleText(text);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (parsed.count) {
                self.cues = parsed;
            }
            if (completion) completion(parsed.count > 0);
        });
    }] resume];
}

@end

#pragma mark - Разбор

static double ParseTimestamp(NSString* value) {
    NSString* normalized = [[value stringByReplacingOccurrencesOfString:@"," withString:@"."] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    double total = 0;
    for (NSString* part in [normalized componentsSeparatedByString:@":"]) {
        total = total * 60.0 + part.doubleValue;
    }
    return total;
}

static BOOL LooksLikeTimestamp(NSString* value) {
    NSString* trimmed = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmed.length >= 4 && [trimmed rangeOfString:@":"].location != NSNotFound && isdigit([trimmed characterAtIndex:0]);
}

static NSString* DecodeEntities(NSString* text) {
    if ([text rangeOfString:@"&"].location == NSNotFound) {
        return text;
    }
    NSMutableString* result = [text mutableCopy];
    NSDictionary<NSString*, NSString*>* entities = @{
        @"&nbsp;": @" ", @"&lt;": @"<", @"&gt;": @">", @"&quot;": @"\"", @"&#39;": @"'", @"&apos;": @"'",
        @"&lrm;": @"", @"&rlm;": @"", @"&amp;": @"&"
    };
    for (NSString* key in @[@"&nbsp;", @"&lt;", @"&gt;", @"&quot;", @"&#39;", @"&apos;", @"&lrm;", @"&rlm;", @"&amp;"]) {
        [result replaceOccurrencesOfString:key withString:entities[key] options:0 range:NSMakeRange(0, result.length)];
    }
    return result;
}

static NSString* StripMarkup(NSString* text) {
    static NSRegularExpression* tags = nil;
    static NSRegularExpression* braces = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tags = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:0 error:nil];
        braces = [NSRegularExpression regularExpressionWithPattern:@"\\{[^}]*\\}" options:0 error:nil];
    });
    NSString* result = [tags stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
    result = [braces stringByReplacingMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    result = DecodeEntities(result);
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static AniLotSubtitleCue* MakeCue(double start, double end, NSString* text) {
    if (text.length == 0 || end <= start) {
        return nil;
    }
    AniLotSubtitleCue* cue = [AniLotSubtitleCue new];
    cue.start = start;
    cue.end = end;
    cue.text = text;
    return cue;
}

static NSArray<AniLotSubtitleCue*>* ParseVTTOrSRT(NSString* text) {
    NSMutableArray<AniLotSubtitleCue*>* cues = [NSMutableArray new];
    NSArray<NSString*>* lines = [text componentsSeparatedByString:@"\n"];
    NSUInteger i = 0;
    while (i < lines.count) {
        NSString* line = lines[i];
        NSRange arrow = [line rangeOfString:@"-->"];
        if (arrow.location == NSNotFound) {
            i++;
            continue;
        }
        NSString* left = [line substringToIndex:arrow.location];
        NSString* right = [[line substringFromIndex:arrow.location + arrow.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // после времени окончания в WebVTT могут идти настройки позиции: «00:01.000 line:90%»
        NSString* right_time = [[right componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] firstObject] ?: @"";
        i++;
        if (!LooksLikeTimestamp(left) || !LooksLikeTimestamp(right_time)) {
            continue;
        }
        NSMutableArray<NSString*>* body = [NSMutableArray new];
        while (i < lines.count) {
            NSString* text_line = lines[i];
            if ([[text_line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                break;
            }
            [body addObject:text_line];
            i++;
        }
        AniLotSubtitleCue* cue = MakeCue(ParseTimestamp(left), ParseTimestamp(right_time), StripMarkup([body componentsJoinedByString:@"\n"]));
        if (cue) {
            [cues addObject:cue];
        }
    }
    return cues;
}

static NSArray<AniLotSubtitleCue*>* ParseASS(NSString* text) {
    NSMutableArray<AniLotSubtitleCue*>* cues = [NSMutableArray new];
    NSInteger start_index = 1, end_index = 2, text_index = 9, field_count = 10;
    BOOL in_events = NO;
    for (NSString* raw in [text componentsSeparatedByString:@"\n"]) {
        NSString* line = [raw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([line hasPrefix:@"["]) {
            in_events = [line.lowercaseString isEqualToString:@"[events]"];
            continue;
        }
        if (!in_events) {
            continue;
        }
        if ([line hasPrefix:@"Format:"]) {
            NSArray<NSString*>* names = [[line substringFromIndex:7] componentsSeparatedByString:@","];
            field_count = (NSInteger)names.count;
            for (NSUInteger n = 0; n < names.count; n++) {
                NSString* name = [[names[n] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
                if ([name isEqualToString:@"start"]) start_index = (NSInteger)n;
                else if ([name isEqualToString:@"end"]) end_index = (NSInteger)n;
                else if ([name isEqualToString:@"text"]) text_index = (NSInteger)n;
            }
            continue;
        }
        if (![line hasPrefix:@"Dialogue:"]) {
            continue;
        }
        NSString* payload = [line substringFromIndex:9];
        // поле Text — последнее и может содержать запятые
        NSMutableArray<NSString*>* fields = [NSMutableArray new];
        NSString* rest = payload;
        for (NSInteger n = 0; n < field_count - 1; n++) {
            NSRange comma = [rest rangeOfString:@","];
            if (comma.location == NSNotFound) {
                break;
            }
            [fields addObject:[rest substringToIndex:comma.location]];
            rest = [rest substringFromIndex:comma.location + 1];
        }
        [fields addObject:rest];
        if (start_index >= (NSInteger)fields.count || end_index >= (NSInteger)fields.count || text_index >= (NSInteger)fields.count) {
            continue;
        }
        NSString* body = fields[(NSUInteger)text_index];
        if ([body rangeOfString:@"\\p1"].location != NSNotFound) {
            continue; // векторная графика
        }
        body = [body stringByReplacingOccurrencesOfString:@"\\N" withString:@"\n"];
        body = [body stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        body = [body stringByReplacingOccurrencesOfString:@"\\h" withString:@" "];
        AniLotSubtitleCue* cue = MakeCue(ParseTimestamp(fields[(NSUInteger)start_index]), ParseTimestamp(fields[(NSUInteger)end_index]), StripMarkup(body));
        if (cue) {
            [cues addObject:cue];
        }
    }
    return cues;
}

NSArray<AniLotSubtitleCue*>* AniLotParseSubtitleText(NSString* text) {
    if (text.length == 0) {
        return @[];
    }
    NSString* normalized = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    normalized = [normalized stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    if ([normalized hasPrefix:@"\uFEFF"]) {
        normalized = [normalized substringFromIndex:1];
    }
    NSArray<AniLotSubtitleCue*>* cues = nil;
    if ([normalized rangeOfString:@"[Events]" options:NSCaseInsensitiveSearch].location != NSNotFound &&
        [normalized rangeOfString:@"Dialogue:"].location != NSNotFound) {
        cues = ParseASS(normalized);
    } else {
        cues = ParseVTTOrSRT(normalized);
    }
    return [cues sortedArrayUsingComparator:^NSComparisonResult(AniLotSubtitleCue* a, AniLotSubtitleCue* b) {
        if (a.start < b.start) return NSOrderedAscending;
        if (a.start > b.start) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

#pragma mark - Поиск ссылок

static NSString* LabelFromURLString(NSString* url) {
    NSString* name = [[[url componentsSeparatedByString:@"?"].firstObject lastPathComponent] lowercaseString];
    NSCharacterSet* separators = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    for (NSString* token in [name componentsSeparatedByCharactersInSet:separators]) {
        if ([token isEqualToString:@"ru"] || [token isEqualToString:@"rus"] || [token isEqualToString:@"russian"]) {
            return L(@"app.player.subtitles.russian", @"Русский");
        }
        if ([token isEqualToString:@"en"] || [token isEqualToString:@"eng"] || [token isEqualToString:@"english"]) {
            return @"English";
        }
    }
    return nil;
}

static NSURL* AbsoluteURL(NSString* link, NSURL* base_url) {
    NSString* clean = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    clean = [clean stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    clean = [clean stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    if (clean.length == 0) {
        return nil;
    }
    if ([clean hasPrefix:@"//"]) {
        clean = [@"https:" stringByAppendingString:clean];
    }
    NSURL* url = nil;
    if ([clean hasPrefix:@"http://"] || [clean hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:clean];
    } else if (base_url) {
        url = [[NSURL URLWithString:clean relativeToURL:base_url] absoluteURL];
    }
    if (!url || !url.host.length) {
        return nil;
    }
    if ([url.scheme isEqualToString:@"http"]) {
        // ATS: для медиа разрешён http, но файл субтитров запрашивается через NSURLSession — используем https
        NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        components.scheme = @"https";
        url = components.URL ?: url;
    }
    return url;
}

static BOOL LooksLikeSubtitleFile(NSString* link) {
    NSString* path = [[link componentsSeparatedByString:@"?"].firstObject lowercaseString];
    return [path hasSuffix:@".vtt"] || [path hasSuffix:@".srt"] || [path hasSuffix:@".ass"] || [path hasSuffix:@".ssa"];
}

NSArray<AniLotSubtitleTrack*>* AniLotFindSubtitleTracks(NSString* source, NSURL* base_url) {
    if (source.length == 0) {
        return @[];
    }
    NSString* text = [source stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    text = [text stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    NSString* referer = base_url.host ? [NSString stringWithFormat:@"%@://%@/", base_url.scheme ?: @"https", base_url.host] : nil;

    NSMutableArray<AniLotSubtitleTrack*>* tracks = [NSMutableArray new];
    NSMutableSet<NSString*>* seen = [NSMutableSet new];
    void (^add)(NSString*, NSString*) = ^(NSString* label, NSString* link) {
        NSURL* url = AbsoluteURL(link, base_url);
        if (!url || [seen containsObject:url.absoluteString]) {
            return;
        }
        [seen addObject:url.absoluteString];
        AniLotSubtitleTrack* track = [AniLotSubtitleTrack new];
        track.url = url;
        NSString* name = [label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (name.length == 0) {
            name = LabelFromURLString(url.absoluteString);
        }
        track.label = name.length ? name : L(@"app.player.subtitles.generic", @"Субтитры");
        if (referer) {
            track.headers = @{@"Referer": referer};
        }
        [tracks addObject:track];
    };

    // 1) <track kind="subtitles" src="..." label="..." srclang="..">
    NSRegularExpression* track_tag = [NSRegularExpression regularExpressionWithPattern:@"<track\\b[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    for (NSTextCheckingResult* m in [track_tag matchesInString:text options:0 range:NSMakeRange(0, text.length)]) {
        NSString* tag = [text substringWithRange:m.range];
        NSString* (^attr)(NSString*) = ^NSString*(NSString* name) {
            NSString* pattern = [NSString stringWithFormat:@"\\b%@\\s*=\\s*[\"']([^\"']*)[\"']", name];
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult* found = [regex firstMatchInString:tag options:0 range:NSMakeRange(0, tag.length)];
            return found ? [tag substringWithRange:[found rangeAtIndex:1]] : nil;
        };
        NSString* kind = attr(@"kind").lowercaseString;
        if (kind.length && ![kind isEqualToString:@"subtitles"] && ![kind isEqualToString:@"captions"]) {
            continue;
        }
        NSString* src = attr(@"src");
        if (src.length) {
            add(attr(@"label") ?: attr(@"srclang"), src);
        }
    }

    // 2) playerjs: "subtitle":"[Русский]https://a.vtt,[English]https://b.vtt"
    NSRegularExpression* playerjs = [NSRegularExpression regularExpressionWithPattern:@"[\"']?subtitles?[\"']?\\s*:\\s*[\"']([^\"']+)[\"']" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression* labeled = [NSRegularExpression regularExpressionWithPattern:@"\\[([^\\]]+)\\]\\s*((?:https?:)?//[^,\\s\"'<>\\\\]+|/[^,\\s\"'<>\\\\]+)" options:0 error:nil];
    for (NSTextCheckingResult* m in [playerjs matchesInString:text options:0 range:NSMakeRange(0, text.length)]) {
        NSString* value = [text substringWithRange:[m rangeAtIndex:1]];
        for (NSTextCheckingResult* item in [labeled matchesInString:value options:0 range:NSMakeRange(0, value.length)]) {
            add([value substringWithRange:[item rangeAtIndex:1]], [value substringWithRange:[item rangeAtIndex:2]]);
        }
    }

    // 3) JSON/JS: {"file":"https://x.vtt","label":"Russian"} (в любом порядке ключей)
    NSRegularExpression* object_regex = [NSRegularExpression regularExpressionWithPattern:@"\\{[^{}]{0,600}?\\.(?:vtt|srt|ass|ssa)[^{}]{0,600}?\\}" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression* url_in_object = [NSRegularExpression regularExpressionWithPattern:@"[\"']((?:https?:)?//[^\"'\\s<>]+?\\.(?:vtt|srt|ass|ssa)(?:\\?[^\"'\\s<>]*)?|/[^\"'\\s<>]+?\\.(?:vtt|srt|ass|ssa)(?:\\?[^\"'\\s<>]*)?)[\"']" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression* label_in_object = [NSRegularExpression regularExpressionWithPattern:@"[\"'](?:label|name|title|lang|language)[\"']\\s*:\\s*[\"']([^\"']+)[\"']" options:NSRegularExpressionCaseInsensitive error:nil];
    for (NSTextCheckingResult* m in [object_regex matchesInString:text options:0 range:NSMakeRange(0, text.length)]) {
        NSString* object = [text substringWithRange:m.range];
        NSTextCheckingResult* url_match = [url_in_object firstMatchInString:object options:0 range:NSMakeRange(0, object.length)];
        if (!url_match) {
            continue;
        }
        NSTextCheckingResult* label_match = [label_in_object firstMatchInString:object options:0 range:NSMakeRange(0, object.length)];
        add(label_match ? [object substringWithRange:[label_match rangeAtIndex:1]] : nil, [object substringWithRange:[url_match rangeAtIndex:1]]);
    }

    // 4) любые другие ссылки на файлы субтитров
    NSRegularExpression* bare = [NSRegularExpression regularExpressionWithPattern:@"((?:https?:)?//[^\\s\"'<>\\\\,\\]\\[]+?\\.(?:vtt|srt|ass|ssa)(?:\\?[^\\s\"'<>\\\\,\\]\\[]*)?)" options:NSRegularExpressionCaseInsensitive error:nil];
    for (NSTextCheckingResult* m in [bare matchesInString:text options:0 range:NSMakeRange(0, text.length)]) {
        NSString* link = [text substringWithRange:[m rangeAtIndex:1]];
        if (LooksLikeSubtitleFile(link)) {
            add(nil, link);
        }
    }

    // уникальные подписи: «Русский», «Русский 2»
    NSMutableDictionary<NSString*, NSNumber*>* counts = [NSMutableDictionary new];
    for (AniLotSubtitleTrack* track in tracks) {
        NSInteger n = [counts[track.label] integerValue] + 1;
        counts[track.label] = @(n);
        if (n > 1) {
            track.label = [NSString stringWithFormat:@"%@ %ld", track.label, (long)n];
        }
    }
    return tracks;
}
