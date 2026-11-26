//
//  PlayerViewController.h
//  AniLot
//
//  Собственный плеер приложения (без AVPlayerViewController) и менеджер загрузок серий.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "LibanixartApi.h"

@interface PlayerController : NSObject
@property(nonatomic, readonly, retain, getter = getPlayer) UIViewController* player;
/* Список серий текущего источника (@{@"position": NSNumber, @"title": NSString}, по возрастанию).
   Берётся при следующем запуске серии и нужен для «Автоматически следующая серия». */
@property(nonatomic, copy) NSArray<NSDictionary*>* pending_playlist;

-(instancetype)init;

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;
-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;
-(void)playWithURL:(NSURL*)url;
-(void)playLocalURL:(NSURL*)url title:(NSString*)title;
-(void)playLocalURL:(NSURL*)url title:(NSString*)title resumeKey:(NSString*)resume_key;

-(UIViewController*)getPlayer;

+(instancetype)sharedInstance;

@end

#pragma mark - Настройки плеера AniLot

extern NSString* const AniLotSettingResumeKey;       // запоминать позицию серии (по умолчанию YES)
extern NSString* const AniLotSettingSkipButtonsKey;  // кнопка пропуска опенинга/эндинга (по умолчанию YES)
extern NSString* const AniLotSettingAutoSkipKey;     // автоматический пропуск (по умолчанию NO)

BOOL AniLotSettingBool(NSString* key, BOOL default_value);
void AniLotSetSettingBool(NSString* key, BOOL value);

/* Идентификаторы: internal, vlc, outplayer, nplayer, share */
NSArray<NSString*>* AniLotExternalPlayerIDs(void);
NSString* AniLotExternalPlayerName(NSString* identifier);
NSString* AniLotExternalPlayerID(void);
void AniLotSetExternalPlayerID(NSString* identifier);

#pragma mark - MAL ID (используется синхронизацией с Shikimori: id аниме в Shikimori = MAL ID)

/* MAL ID релиза. Берёт из кэша или ищет через Shikimori; nil — не найден. Блокирует поток — вызывать не из главного. */
NSString* AniLotLookupMalID(long long release_id, NSString* title, NSInteger year, NSInteger episodes_total);
/* Релиз Anixart, для которого MAL ID уже известен из кэша (0 — неизвестно) */
long long AniLotKnownReleaseIDForMalID(long long mal_id);

#pragma mark - Загрузки

extern NSString* const DownloadManagerDidUpdateNotification;
/* серия отмечена просмотренной автопереходом. userInfo: release_id, source_id, position (NSNumber) */
extern NSString* const AniLotEpisodeWatchedNotification;

typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateQueued = 0,
    DownloadStateDownloading = 1,
    DownloadStateCompleted = 2,
    DownloadStateFailed = 3
};

@interface DownloadItem : NSObject
@property(nonatomic, copy) NSString* identifier;
@property(nonatomic, copy) NSString* title;          // серия и озвучка
@property(nonatomic, copy) NSString* release_title;  // название аниме
@property(nonatomic, copy) NSString* error_text;
@property(nonatomic) BOOL cancelled;
@property(nonatomic) long long release_id;
@property(nonatomic) long long source_id;
@property(nonatomic) long position;
@property(nonatomic) DownloadState state;
@property(nonatomic) double progress;
@property(nonatomic, copy) NSString* relative_path;
@property(nonatomic) BOOL is_hls;

-(NSURL*)localURL;
@end

@interface DownloadManager : NSObject

+(instancetype)sharedInstance;

-(NSArray<DownloadItem*>*)items;
-(DownloadItem*)itemForReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position;
/* completion вызывается, когда ссылка на поток найдена и загрузка запущена (errored = YES если не удалось) */
-(void)downloadReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title completion:(void(^)(BOOL errored))completion;
-(void)deleteItem:(DownloadItem*)item;

@end
