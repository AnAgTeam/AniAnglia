//
//  ApiDataController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppDataController.h"
#import "LibanixartApi.h"

@interface AppSettingsDataController ()
@property(nonatomic) NSUserDefaults* user_defaults;
@property(nonatomic, retain) NSMutableDictionary* settings_dict;
@end

@interface AppDataController ()
@property(nonatomic, retain) AppSettingsDataController* settings_controller;
@end

@implementation AppSettingsDataController

+(NSDictionary*)getDefaults {
    return @{
        // -- appearance
        app_settings_keys::Appearance::theme: @(static_cast<int>(app_settings_keys::Appearance::Theme::System)),
        app_settings_keys::Appearance::main_display_style: @(static_cast<int>(app_settings_keys::Appearance::DisplayStyle::Table)),
        // -- playback
        app_settings_keys::Playback::default_player: @(static_cast<int>(app_settings_keys::Playback::DefaultPlayer::Internal)),
        app_settings_keys::Playback::preffered_quality: @"720",
        app_settings_keys::Playback::default_skip_time: @90,
        app_settings_keys::Playback::auto_next_video: @(NO),
        app_settings_keys::Playback::remember_source: @(NO),
        // -- data control
        app_settings_keys::DataControl::max_cache_size: @(10 * 1024 * 1024),
        // -- general
        app_settings_keys::General::alternative_connection: @(NO),
    };
}

-(instancetype)initWithUserDefaults:(NSUserDefaults*)user_defaults {
    self = [super init];
    
    _user_defaults = user_defaults;
    _settings_dict = [[_user_defaults objectForKey:@"settings"] mutableCopy];
    
    return self;
}

-(void)saveSettings {
    [_user_defaults setObject:_settings_dict forKey:@"settings"];
}

-(void)setSettingsObject:(id)object atKey:(NSString*)key {
    // TODO. Better not to use this
}
// -- appearance
-(app_settings_keys::Appearance::Theme)getTheme {
    NSNumber* theme = [_settings_dict valueForKey:app_settings_keys::Appearance::theme];
    return static_cast<app_settings_keys::Appearance::Theme>([theme longValue]);
}
-(void)setTheme:(app_settings_keys::Appearance::Theme)theme {
    [_settings_dict setValue:@(static_cast<int>(theme)) forKey:app_settings_keys::Appearance::theme];
    [self saveSettings];
}
-(app_settings_keys::Appearance::DisplayStyle)getMainDisplayStyle {
    NSNumber* display_style = [_settings_dict valueForKey:app_settings_keys::Appearance::main_display_style];
    return static_cast<app_settings_keys::Appearance::DisplayStyle>([display_style longValue]);
}
-(void)setMainDisplayStyle:(app_settings_keys::Appearance::DisplayStyle)display_style {
    [_settings_dict setValue:@(static_cast<int>(display_style)) forKey:app_settings_keys::Appearance::main_display_style];
    [self saveSettings];
}

// -- playback
-(app_settings_keys::Playback::DefaultPlayer)getDefaultPlayer {
    NSNumber* default_player = [_settings_dict valueForKey:app_settings_keys::Playback::default_player];
    return static_cast<app_settings_keys::Playback::DefaultPlayer>([default_player longValue]);
}
-(void)setDefaultPlayer:(app_settings_keys::Playback::DefaultPlayer)default_player {
    [_settings_dict setValue:@(static_cast<int>(default_player)) forKey:app_settings_keys::Playback::default_player];
    [self saveSettings];
}
-(NSString*)getPrefferedQuality {
    NSString* preffered_quality = [_settings_dict valueForKey:app_settings_keys::Playback::preffered_quality];
    return preffered_quality;
}
-(void)setPrefferedQuality:(NSString*)preffered_quality {
    [_settings_dict setValue:preffered_quality forKey:app_settings_keys::Playback::preffered_quality];
    [self saveSettings];
}
-(std::chrono::system_clock::duration)getDefaultSkipTime {
    NSNumber* default_skip_time = [_settings_dict valueForKey:app_settings_keys::Playback::preffered_quality];
    return std::chrono::seconds([default_skip_time longValue]);
}
-(void)setDefaultSkipTime:(std::chrono::system_clock::duration)default_skip_time {
    std::chrono::seconds seconds = std::chrono::floor<std::chrono::seconds>(default_skip_time);
    [_settings_dict setValue:@(seconds.count()) forKey:app_settings_keys::Playback::default_skip_time];
    [self saveSettings];
}
-(BOOL)getAutoNextVideo {
    NSNumber* auto_next_video = [_settings_dict valueForKey:app_settings_keys::Playback::auto_next_video];
    return [auto_next_video boolValue];
}
-(void)setAutoNextVideo:(BOOL)auto_next_video {
    [_settings_dict setValue:@(auto_next_video) forKey:app_settings_keys::Playback::auto_next_video];
    [self saveSettings];
}
-(BOOL)setRememberSource {
    NSNumber* remember_source = [_settings_dict valueForKey:app_settings_keys::Playback::remember_source];
    return [remember_source boolValue];
}
-(void)setRememberSource:(BOOL)remember_source {
    [_settings_dict setValue:@(remember_source) forKey:app_settings_keys::Playback::remember_source];
    [self saveSettings];
}

// -- notifications

// -- data control
-(NSInteger)getMaxCacheSizeBytes {
    NSNumber* max_cache_size_bytes = [_settings_dict valueForKey:app_settings_keys::DataControl::max_cache_size];
    return [max_cache_size_bytes longValue];
}
-(void)setMaxCacheSizeBytes:(NSInteger)max_cache_size_bytes {
    [_settings_dict setValue:@(max_cache_size_bytes) forKey:app_settings_keys::DataControl::max_cache_size];
    [self saveSettings];
}

// -- general
-(BOOL)getAlternativeConnection {
    NSNumber* alternative_connection = [_settings_dict valueForKey:app_settings_keys::General::alternative_connection];
    return [alternative_connection boolValue];
}
-(void)setAlternativeConnection:(BOOL)alternative_connection {
    [_settings_dict setValue:@(alternative_connection) forKey:app_settings_keys::General::alternative_connection];
    [self saveSettings];
}

@end

@interface AppDataController ()
@property(nonatomic, retain) NSUserDefaults* user_defaults;
@end

@implementation AppDataController

-(instancetype)init {
    self = [super init];
    
    _user_defaults = [NSUserDefaults standardUserDefaults];
    [_user_defaults registerDefaults:@{
        @"search_history": @[],
        @"token": @"",
        @"profile_id": @0,
        @"settings": [AppSettingsDataController getDefaults]
    }];
    _settings_controller = [[AppSettingsDataController alloc] initWithUserDefaults:_user_defaults];
    
    return self;
}

-(NSString*)getToken {
    return [_user_defaults stringForKey:@"token"];
}
-(void)setToken:(NSString*)token {
    [_user_defaults setObject:token forKey:@"token"];
}
-(anixart::ProfileID)getMyProfileID {
    return static_cast<anixart::ProfileID>([_user_defaults integerForKey:@"profile_id"]);
}
-(void)setMyProfileID:(anixart::ProfileID)profile_id {
    [_user_defaults setInteger:static_cast<int64_t>(profile_id) forKey:@"profile_id"];
}
-(NSArray<NSString*>*)getSearchHistory {
    return [_user_defaults arrayForKey:@"search_history"];
}
-(void)addSearchHistoryItem:(NSString*)item {
    if ([item length] == 0) {
        NSLog(@"WARNING: empty history item! (addSearchHistoryItem:)");
        return;
    }
    NSMutableArray<NSString*>* history = [[_user_defaults arrayForKey:@"search_history"] mutableCopy];
    for (NSString* history_item in history) {
        if ([history_item isEqual:item]) {
            [history removeObject:history_item];
            break;
        }
    }
    [history insertObject:item atIndex:0];
    [_user_defaults setObject:history forKey:@"search_history"];
}
-(NSUInteger)getSearchHistoryLength {
    return [[self getSearchHistory] count];
}
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index {
    return [[self getSearchHistory] objectAtIndex:index];
}

-(AppSettingsDataController*)getSettingsController {
    return _settings_controller;
}

+(instancetype)sharedInstance {
    static AppDataController* shared_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        shared_instance = [AppDataController new];
    });
    return shared_instance;
}

@end
