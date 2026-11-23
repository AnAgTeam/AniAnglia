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

-(instancetype)init;

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;
-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;
-(void)playWithURL:(NSURL*)url;
-(void)playLocalURL:(NSURL*)url title:(NSString*)title;

-(UIViewController*)getPlayer;

+(instancetype)sharedInstance;

@end

#pragma mark - Загрузки

extern NSString* const DownloadManagerDidUpdateNotification;

typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateQueued = 0,
    DownloadStateDownloading = 1,
    DownloadStateCompleted = 2,
    DownloadStateFailed = 3
};

@interface DownloadItem : NSObject
@property(nonatomic, copy) NSString* identifier;
@property(nonatomic, copy) NSString* title;
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
