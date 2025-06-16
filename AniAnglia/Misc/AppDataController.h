//
//  AppDataController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "LibanixartApi.h"

namespace app_settings {
    constexpr NSString* notification_name = @"AppSettingsDataControllerValueChanged";
    constexpr NSString* notification_info_key = @"SettingName";
    constexpr NSString* notification_info_value = @"SettingValue";
struct Appearance {
    enum class Theme {
        Light = 0,
        Dark = 1,
        System = 2
    };
    enum class DisplayStyle {
        Table = 0,
        Cards = 1
    };
    
    // kindof Theme enum
    static constexpr NSString* theme = @"theme";
    // kindof DisplayStyle enum
    static constexpr NSString* main_display_style = @"main_display_style";
};
struct Playback {
    enum class DefaultPlayer {
        None = 0,
        Internal = 1
    };
    
    // kindof DefaultPlayer enum
    static constexpr NSString* default_player = @"default_player";
    // kindof NSString*
    static constexpr NSString* preffered_quality = @"preffered_quality";
    // kindof NSInteger seconds
    static constexpr NSString* default_skip_time = @"default_skip_time";
    // kindof BOOL
    static constexpr NSString* auto_next_video = @"auto_next_video";
    // kindof BOOL
    static constexpr NSString* remember_source = @"remember_source";
};
struct Notifications {
    // TODO
};
struct DataControl {
    // kindof NSInteger bytes
    static constexpr NSString* max_cache_size = @"max_cache_size";
};
struct General {
    // kindof BOOL
    static constexpr NSString* alternative_connection = @"alternative_connection";
};
};

@interface AppDataReleaseTypeObject
@property(nonatomic, retain) NSString* name;
@property(nonatomic) NSInteger id;

+(instancetype)typeFromObject:(NSDictionary*)object;
-(instancetype)initFromObject:(NSDictionary*)object;
-(NSDictionary*)typeToObject;
@end

@interface AppSettingsDataController : NSObject
-(void)setSettingsObject:(id)object atKey:(NSString*)key;
// -- appearance
-(app_settings::Appearance::Theme)getTheme;
-(void)setTheme:(app_settings::Appearance::Theme)theme;
-(app_settings::Appearance::DisplayStyle)getMainDisplayStyle;
-(void)setMainDisplayStyle:(app_settings::Appearance::DisplayStyle)display_style;

// -- playback
-(app_settings::Playback::DefaultPlayer)getDefaultPlayer;
-(void)setDefaultPlayer:(app_settings::Playback::DefaultPlayer)default_player;
-(NSString*)getPrefferedQuality;
-(void)setPrefferedQuality:(NSString*)preffered_quality;
-(std::chrono::system_clock::duration)getDefaultSkipTime;
-(void)setDefaultSkipTime:(std::chrono::system_clock::duration)default_skip_time;
-(BOOL)getAutoNextVideo;
-(void)setAutoNextVideo:(BOOL)auto_next_video;
-(BOOL)setRememberSource;
-(void)setRememberSource:(BOOL)remember_source;

// -- notifications

// -- data control
-(NSInteger)getMaxCacheSizeBytes;
-(void)setMaxCacheSizeBytes:(NSInteger)max_cache_size_bytes;

// -- general
-(BOOL)getAlternativeConnection;
-(void)setAlternativeConnection:(BOOL)alternative_connection;

@end

@interface AppDataController : NSObject

-(instancetype)init;

-(NSString*)getToken;
-(void)setToken:(NSString*)token;
-(anixart::ProfileID)getMyProfileID;
-(void)setMyProfileID:(anixart::ProfileID)profile_id;

-(NSArray<NSString*>*)getSearchHistory;
-(void)addSearchHistoryItem:(NSString*)item;
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index;
-(void)removeSearchHistoryItemAtIndex:(NSInteger)index;
-(NSUInteger)getSearchHistoryLength;

-(NSArray<AppDataReleaseTypeObject*>*)getSavedReleaseTypes:(NSInteger)release_id;

-(AppSettingsDataController*)getSettingsController;

+(instancetype)sharedInstance;
@end

