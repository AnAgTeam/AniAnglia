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
        app_settings::Appearance::theme: @(static_cast<int>(app_settings::Appearance::Theme::System)),
        app_settings::Appearance::main_display_style: @(static_cast<int>(app_settings::Appearance::DisplayStyle::Table)),
        // -- playback
        app_settings::Playback::default_player: @(static_cast<int>(app_settings::Playback::DefaultPlayer::Internal)),
        app_settings::Playback::preffered_quality: @"720",
        app_settings::Playback::default_skip_time: @90,
        app_settings::Playback::auto_next_video: @(NO),
        app_settings::Playback::remember_source: @(NO),
        // -- data control
        app_settings::DataControl::max_cache_size: @(10 * 1024 * 1024),
        // -- general
        app_settings::General::alternative_connection: @(NO),
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

-(void)postNotificationForObject:(id)object atKey:(NSString*)key {
    NSNotification* notification = [NSNotification notificationWithName:(app_settings::notification_name) object:self userInfo:@{
        (app_settings::notification_info_key): key,
        (app_settings::notification_info_value): object
    }];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
-(void)setSettingsObject:(id)object atKey:(NSString*)key {
    [_settings_dict setValue:object forKey:key];
    [self saveSettings];
    [self postNotificationForObject:object atKey:key];
}
-(id)getSettingsObjectAtKey:(NSString*)key {
    return [_settings_dict valueForKey:key];
}

// -- appearance
-(app_settings::Appearance::Theme)getTheme {
    NSNumber* theme = [self getSettingsObjectAtKey:app_settings::Appearance::theme];
    return static_cast<app_settings::Appearance::Theme>([theme longValue]);
}
-(void)setTheme:(app_settings::Appearance::Theme)theme {
    [self setSettingsObject:@(static_cast<int>(theme)) atKey:app_settings::Appearance::theme];
}
-(app_settings::Appearance::DisplayStyle)getMainDisplayStyle {
    NSNumber* display_style = [self getSettingsObjectAtKey:app_settings::Appearance::main_display_style];
    return static_cast<app_settings::Appearance::DisplayStyle>([display_style longValue]);
}
-(void)setMainDisplayStyle:(app_settings::Appearance::DisplayStyle)display_style {
    [self setSettingsObject:@(static_cast<int>(display_style)) atKey:app_settings::Appearance::main_display_style];
}

// -- playback
-(app_settings::Playback::DefaultPlayer)getDefaultPlayer {
    NSNumber* default_player = [self getSettingsObjectAtKey:app_settings::Playback::default_player];
    return static_cast<app_settings::Playback::DefaultPlayer>([default_player longValue]);
}
-(void)setDefaultPlayer:(app_settings::Playback::DefaultPlayer)default_player {
    [self setSettingsObject:@(static_cast<int>(default_player)) atKey:app_settings::Playback::default_player];
}
-(NSString*)getPrefferedQuality {
    NSString* preffered_quality = [self getSettingsObjectAtKey:app_settings::Playback::preffered_quality];
    return preffered_quality;
}
-(void)setPrefferedQuality:(NSString*)preffered_quality {
    [self setSettingsObject:preffered_quality atKey:app_settings::Playback::preffered_quality];
}
-(std::chrono::system_clock::duration)getDefaultSkipTime {
    NSNumber* default_skip_time = [self getSettingsObjectAtKey:app_settings::Playback::preffered_quality];
    return std::chrono::seconds([default_skip_time longValue]);
}
-(void)setDefaultSkipTime:(std::chrono::system_clock::duration)default_skip_time {
    std::chrono::seconds seconds = std::chrono::floor<std::chrono::seconds>(default_skip_time);
    [self setSettingsObject:@(seconds.count()) atKey:app_settings::Playback::default_skip_time];
}
-(BOOL)getAutoNextVideo {
    NSNumber* auto_next_video = [self getSettingsObjectAtKey:app_settings::Playback::auto_next_video];
    return [auto_next_video boolValue];
}
-(void)setAutoNextVideo:(BOOL)auto_next_video {
    [self setSettingsObject:@(auto_next_video) atKey:app_settings::Playback::auto_next_video];
}
-(BOOL)setRememberSource {
    NSNumber* remember_source = [self getSettingsObjectAtKey:app_settings::Playback::remember_source];
    return [remember_source boolValue];
}
-(void)setRememberSource:(BOOL)remember_source {
    [self setSettingsObject:@(remember_source) atKey:app_settings::Playback::remember_source];
}

// -- notifications

// -- data control
-(NSInteger)getMaxCacheSizeBytes {
    NSNumber* max_cache_size_bytes = [self getSettingsObjectAtKey:app_settings::DataControl::max_cache_size];
    return [max_cache_size_bytes longValue];
}
-(void)setMaxCacheSizeBytes:(NSInteger)max_cache_size_bytes {
    [self setSettingsObject:@(max_cache_size_bytes) atKey:app_settings::DataControl::max_cache_size];
}

// -- general
-(BOOL)getAlternativeConnection {
    NSNumber* alternative_connection = [self getSettingsObjectAtKey:app_settings::General::alternative_connection];
    return [alternative_connection boolValue];
}
-(void)setAlternativeConnection:(BOOL)alternative_connection {
    [self setSettingsObject:@(alternative_connection) atKey:app_settings::General::alternative_connection];
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
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index {
    return [[self getSearchHistory] objectAtIndex:index];
}
-(void)removeSearchHistoryItemAtIndex:(NSInteger)index {
    NSMutableArray<NSString*>* history = [[_user_defaults arrayForKey:@"search_history"] mutableCopy];
    [history removeObjectAtIndex:index];
    [_user_defaults setObject:history forKey:@"search_history"];
}
-(NSUInteger)getSearchHistoryLength {
    return [[self getSearchHistory] count];
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
