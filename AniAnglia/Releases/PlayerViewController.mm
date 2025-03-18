//
//  PlayerViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 07.10.2024.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayerViewController.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "TorrentAVAsset.h"

@interface PlayerViewController : AVPlayerViewController
@property(nonatomic, retain) AVPlayerViewController* player_view_controller;
@property(nonatomic) BOOL in_pip;
@property(nonatomic) BOOL is_visible;
@end

@interface PlayerController ()
@property(atomic) anixart::ReleaseID release_id;
@property(atomic) anixart::EpisodeSourceID source_id;
@property(atomic) long source_position;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic) std::unordered_map<std::string, std::string> streams_arr;
@property(nonatomic, retain) NSURL* selected_stream_url;
@property(nonatomic, retain) PlayerViewController* player_view_controller;
@property(nonatomic, retain) AVPictureInPictureController* pip_controller;

@property(nonatomic, retain) TorrentAVResourceLoaderDelegate* torrent_rc_delegate;
@end

static const std::string_view preferred_quality = "720";
std::string choose_quality(const std::unordered_map<std::string, std::string>& quals, const std::string_view preffered) {
    auto preferred = quals.find(std::string(preffered.data()));
    if (preferred != quals.end()) {
        return preferred->second;
    }		
    long long_quality = 0;
    std::string quality_url;
    for (auto& [q, u] : quals) {
        long this_long_quality = std::stol(q);
        if (long_quality < this_long_quality) {
            long_quality = this_long_quality;
            quality_url.assign(u);
        }
    }
    return quality_url;
}

@implementation PlayerViewController

-(void)viewWillAppear:(BOOL)animated {
    _is_visible = YES;
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    if (!_in_pip) {
        self.player = nil;
    }
    _is_visible = NO;
    [super viewDidDisappear:animated];
}

@end

@implementation PlayerController

-(instancetype)init {
    self = [super init];
    
    _release_id = static_cast<anixart::ReleaseID>(-1);
    _source_id = static_cast<anixart::EpisodeSourceID>(-1);
    _source_position = -1;
    _api_proxy = [LibanixartApi sharedInstance];
    _player_view_controller = [PlayerViewController new];
    [_player_view_controller setDelegate:self];
    [self setupLayout];
    _torrent_rc_delegate = [TorrentAVResourceLoaderDelegate new];
    
    return self;
}

-(void)loadStreamsAndAutoPlay:(BOOL)auto_play completion:(void(^)(BOOL errored))completion_handler {
    __block BOOL stream_founded = NO;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        auto ep_target = self->_api_proxy.api->episodes().get_episode_target(self->_release_id, self->_source_id, static_cast<int32_t>(self->_source_position));
        self->_streams_arr = self->_api_proxy.parsers->extract_info(ep_target->url);
        auto selected_stream = choose_quality(self->_streams_arr, preferred_quality);
        self->_selected_stream_url = [NSURL URLWithString:TO_NSSTRING(selected_stream)];
        stream_founded = !self->_streams_arr.empty();
        return YES;
    } withUICompletion:^{
        completion_handler(!stream_founded);
        if (!stream_founded) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.player.stream_not_found_error.title", "") message:NSLocalizedString(@"app.player.stream_not_found_error.message", "") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* default_action = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.player.stream_not_found_error.default_action.text", "") style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {
                [self->_player_view_controller dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:default_action];
            [self showViewController:alert];
            return;
        }
        if (auto_play) {
            [self runPlayer];
        }
    }];
}

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler {
    _release_id = release_id;
    _source_id = source_id;
    _source_position = position;
    
//    _pip_controller = [AVPictureInPictureController alloc] init;
    
    _player_view_controller.modalPresentationStyle = UIModalPresentationFullScreen;
    _player_view_controller.player = nil;
    
    [_pip_controller setDelegate:self];
    [self loadStreamsAndAutoPlay:YES completion:completion_handler];
    if (auto_show) {
        [self showViewController:_player_view_controller];
    }
}

-(void)showAndRunPlayer {
    [self showViewController:_player_view_controller];
    [self runPlayer];
}

-(void)showViewController:(UIViewController*)view_controller {
    UIViewController* top_view_controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController]; // should be MainTabBarController
    [top_view_controller presentViewController:view_controller animated:NO completion:nil];
}

-(void)playWithURL:(NSURL*)url {
    _selected_stream_url = url;
    [self runPlayer];
}

-(void)runPlayer {
    _player_view_controller.player = [AVPlayer playerWithURL:_selected_stream_url];
    AVURLAsset* asset = (AVURLAsset*)_player_view_controller.player.currentItem.asset;
    [asset.resourceLoader setDelegate:_torrent_rc_delegate queue:dispatch_queue_create("TorrentRepo loader", nil)];
    [_player_view_controller.player play];
    
    AVMutableMetadataItem* title = [AVMutableMetadataItem new];
    title.identifier = AVMetadataCommonIdentifierTitle;
    title.value = @"YO";
    title.extendedLanguageTag = @"und";
    AVMutableMetadataItem* desc = [AVMutableMetadataItem new];
    desc.identifier = AVMetadataCommonIdentifierArtist;
    desc.value = @"HO";
    desc.extendedLanguageTag = @"und";
    _player_view_controller.player.currentItem.externalMetadata = @[
        title,
        desc
    ];
}

-(void)setupLayout {
//    _player_view_controller.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(AVPlayerViewController*)getPlayer {
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

-(void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController*)player_view_controller{
    _player_view_controller.in_pip = YES;
}
-(void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController*)player_view_controller {
    _player_view_controller.in_pip = NO;
    if (!_player_view_controller.is_visible) {
        // closed outside application
        _player_view_controller.player = nil;
    }
}

-(void)playerViewController:(AVPlayerViewController *)player_view_controller restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completion_handler {
    [self showViewController:_player_view_controller];
//    completion_handler(YES);
}

@end
