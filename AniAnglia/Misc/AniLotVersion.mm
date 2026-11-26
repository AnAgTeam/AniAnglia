//
//  AniLotVersion.mm
//  AniLot
//
//  Версия установленного релиза AniLot и проверка новых релизов на GitHub.
//

#import "AniLotVersion.h"

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

static NSString* const kUpdateLastCheckKey = @"anilot_update_last_check";
static NSString* const kUpdateLastInfoKey = @"anilot_update_last_info";

NSInteger AniLotReleaseNumber(void) {
    return ANILOT_RELEASE_NUMBER;
}

NSString* AniLotReleaseName(void) {
    return [NSString stringWithFormat:@"v%ld", (long)AniLotReleaseNumber()];
}

NSString* AniLotBuildString(void) {
    NSDictionary* info = [NSBundle mainBundle].infoDictionary;
    return [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"] ?: @"?", info[@"CFBundleVersion"] ?: @"?"];
}

/* Номер релиза из тега или названия: «anilot-9» → 9, «AniLot v10» → 10. Берём последнее число в строке. */
static NSInteger ReleaseNumberFromString(NSString* text) {
    if (text.length == 0) {
        return 0;
    }
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)" options:0 error:nil];
    NSArray<NSTextCheckingResult*>* matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSTextCheckingResult* last = matches.lastObject;
    if (!last) {
        return 0;
    }
    return [[text substringWithRange:[last rangeAtIndex:1]] integerValue];
}

@implementation AniLotUpdateInfo

-(NSString*)displayName {
    if (_number > 0) {
        return [NSString stringWithFormat:@"v%ld", (long)_number];
    }
    return _name.length ? _name : (_tag ?: @"?");
}

-(NSDictionary*)dictionaryRepresentation {
    return @{
        @"tag": _tag ?: @"",
        @"name": _name ?: @"",
        @"notes": _notes ?: @"",
        @"page_url": _page_url ?: @"",
        @"download_url": _download_url ?: @"",
        @"published": @(_published_at.timeIntervalSince1970),
        @"number": @(_number)
    };
}

+(AniLotUpdateInfo*)infoFromDictionary:(NSDictionary*)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    AniLotUpdateInfo* info = [AniLotUpdateInfo new];
    info.tag = dict[@"tag"];
    info.name = dict[@"name"];
    info.notes = dict[@"notes"];
    info.page_url = dict[@"page_url"];
    info.download_url = [dict[@"download_url"] length] ? dict[@"download_url"] : nil;
    double published = [dict[@"published"] doubleValue];
    info.published_at = published > 0 ? [NSDate dateWithTimeIntervalSince1970:published] : nil;
    info.number = [dict[@"number"] integerValue];
    info.is_newer = info.number > AniLotReleaseNumber();
    info.is_older = info.number > 0 && info.number < AniLotReleaseNumber();
    return info;
}

@end

@implementation AniLotUpdateChecker

+(void)checkWithCompletion:(void(^)(AniLotUpdateInfo* info, NSString* error))completion {
    NSURL* url = [NSURL URLWithString:ANILOT_RELEASES_API_URL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 15;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/vnd.github+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"AniLot" forHTTPHeaderField:@"User-Agent"];

    void (^finish)(AniLotUpdateInfo*, NSString*) = ^(AniLotUpdateInfo* info, NSString* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(info, error);
            }
        });
    };

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 0;
        if (error || !data) {
            finish(nil, error.localizedDescription ?: L(@"app.update.error.network", @"Нет соединения с GitHub"));
            return;
        }
        if (status == 404) {
            finish(nil, L(@"app.update.error.no_releases", @"В репозитории пока нет релизов"));
            return;
        }
        if (status == 403 || status == 429) {
            finish(nil, L(@"app.update.error.rate_limit", @"GitHub временно ограничил запросы. Попробуйте позже."));
            return;
        }
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (status != 200 || ![json isKindOfClass:[NSDictionary class]]) {
            finish(nil, [NSString stringWithFormat:L(@"app.update.error.http", @"Неожиданный ответ GitHub (HTTP %ld)"), (long)status]);
            return;
        }
        NSDictionary* release = json;
        AniLotUpdateInfo* info = [AniLotUpdateInfo new];
        info.tag = [release[@"tag_name"] isKindOfClass:[NSString class]] ? release[@"tag_name"] : @"";
        info.name = [release[@"name"] isKindOfClass:[NSString class]] ? release[@"name"] : @"";
        info.notes = [release[@"body"] isKindOfClass:[NSString class]] ? release[@"body"] : @"";
        info.page_url = [release[@"html_url"] isKindOfClass:[NSString class]] ? release[@"html_url"] : ANILOT_RELEASES_PAGE_URL;
        NSString* published = [release[@"published_at"] isKindOfClass:[NSString class]] ? release[@"published_at"] : nil;
        if (published) {
            NSISO8601DateFormatter* formatter = [NSISO8601DateFormatter new];
            info.published_at = [formatter dateFromString:published];
        }
        NSArray* assets = [release[@"assets"] isKindOfClass:[NSArray class]] ? release[@"assets"] : @[];
        for (NSDictionary* asset in assets) {
            if (![asset isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSString* name = [asset[@"name"] isKindOfClass:[NSString class]] ? asset[@"name"] : @"";
            NSString* link = [asset[@"browser_download_url"] isKindOfClass:[NSString class]] ? asset[@"browser_download_url"] : nil;
            if (link && [name.lowercaseString hasSuffix:@".ipa"]) {
                info.download_url = link;
                break;
            }
        }
        info.number = ReleaseNumberFromString(info.tag);
        if (info.number == 0) {
            info.number = ReleaseNumberFromString(info.name);
        }
        info.is_newer = info.number > AniLotReleaseNumber();
        info.is_older = info.number > 0 && info.number < AniLotReleaseNumber();

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[info dictionaryRepresentation] forKey:kUpdateLastInfoKey];
        [defaults setDouble:[NSDate date].timeIntervalSince1970 forKey:kUpdateLastCheckKey];
        finish(info, nil);
    }] resume];
}

+(AniLotUpdateInfo*)lastKnownInfo {
    return [AniLotUpdateInfo infoFromDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kUpdateLastInfoKey]];
}

+(NSDate*)lastCheckDate {
    double value = [[NSUserDefaults standardUserDefaults] doubleForKey:kUpdateLastCheckKey];
    return value > 0 ? [NSDate dateWithTimeIntervalSince1970:value] : nil;
}

+(NSString*)statusSummary {
    NSDate* date = [self lastCheckDate];
    if (!date) {
        return L(@"app.update.never_checked", @"Ещё не проверялось");
    }
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.doesRelativeDateFormatting = YES;
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString* when = [formatter stringFromDate:date];

    AniLotUpdateInfo* info = [self lastKnownInfo];
    if (info.is_newer) {
        return [NSString stringWithFormat:L(@"app.update.summary.available", @"%@ · доступна %@"), when, [info displayName]];
    }
    return [NSString stringWithFormat:L(@"app.update.summary.latest", @"%@ · актуальная версия"), when];
}

@end
