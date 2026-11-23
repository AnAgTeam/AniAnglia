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

static void ResolveStreams(anixart::ReleaseID release_id, anixart::EpisodeSourceID source_id, int32_t position, void (^completion)(NSDictionary<NSString*, NSURL*>* urls)) {
    LibanixartApi* api_proxy = [LibanixartApi sharedInstance];
    __block NSDictionary<NSString*, NSURL*>* result = nil;
    [api_proxy asyncCall:^BOOL(anixart::Api* api) {
        auto ep_target = api->episodes().get_episode_target(release_id, source_id, position);
        auto streams = api_proxy.parsers->extract_info(ep_target->url);
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
        return NO; // asyncCall: YES означает ошибку
    } completion:^(BOOL errored) {
        completion((errored || result.count == 0) ? nil : result);
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

-(void)startWithURL:(NSURL*)url;
-(void)configureWithQualities:(NSDictionary<NSString*, NSURL*>*)urls preferred:(NSString*)preferred;
-(void)showMessage:(NSString*)title message:(NSString*)message closeAfter:(BOOL)close_after;
-(void)stopPlayback;
@end

@interface AniLotPlayerViewController () {
    id _time_observer;
    id _end_observer;
    BOOL _scrubbing;
    float _rate;
    BOOL _overlay_visible;
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
@end

@implementation AniLotPlayerViewController

-(instancetype)init {
    self = [super init];
    _rate = 1.0f;
    _skip_seconds = 90;
    _overlay_visible = YES;
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
    [_overlay addSubview:_quality_button];
    [_overlay addSubview:center_stack];
    [_overlay addSubview:_current_label];
    [_overlay addSubview:_slider];
    [_overlay addSubview:_duration_label];
    
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
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:_speed_button.leadingAnchor constant:-8],
        
        [center_stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [center_stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [_current_label.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [_current_label.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-16],
        [_duration_label.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [_duration_label.bottomAnchor constraintEqualToAnchor:_current_label.bottomAnchor],
        [_slider.leadingAnchor constraintEqualToAnchor:_current_label.trailingAnchor constant:10],
        [_slider.trailingAnchor constraintEqualToAnchor:_duration_label.leadingAnchor constant:-10],
        [_slider.centerYAnchor constraintEqualToAnchor:_current_label.centerYAnchor]
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
    _player = [AVPlayer playerWithURL:url];
    _video_view.playerLayer.player = _player;
    
    __weak AniLotPlayerViewController* weak_self = self;
    _time_observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weak_self updateUI];
    }];
    _end_observer = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* note) {
        AniLotPlayerViewController* strong_self = weak_self;
        if (!strong_self || note.object != strong_self.player.currentItem) {
            return;
        }
        [strong_self setOverlayVisible:YES];
        [strong_self updateUI];
    }];
    [_player playImmediatelyAtRate:_rate];
    [self updateUI];
    [self scheduleHide];
}

-(void)stopPlayback {
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
    
    BOOL waiting = _player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
    if (waiting) {
        [_spinner startAnimating];
    } else {
        [_spinner stopAnimating];
    }
    BOOL playing = _player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    UIImageSymbolConfiguration* conf = [UIImageSymbolConfiguration configurationWithPointSize:46 weight:UIImageSymbolWeightSemibold];
    [_play_button setImage:[UIImage systemImageNamed:(playing || waiting) ? @"pause.fill" : @"play.fill" withConfiguration:conf] forState:UIControlStateNormal];
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
@end

@implementation PlayerController

-(instancetype)init {
    self = [super init];
    return self;
}

-(AniLotPlayerViewController*)makePlayerWithTitle:(NSString*)title {
    AniLotPlayerViewController* controller = [AniLotPlayerViewController new];
    controller.video_title = title;
    controller.skip_seconds = DefaultSkipSeconds();
    _player_view_controller = controller;
    return controller;
}

-(void)showViewController:(UIViewController*)view_controller {
    [TopViewController() presentViewController:view_controller animated:NO completion:nil];
}

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler {
    [self playWithReleaseID:release_id sourceID:source_id position:position title:nil autoShow:auto_show completion:completion_handler];
}

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position title:(NSString*)title autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler {
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:title];
    if (auto_show) {
        [self showViewController:controller];
    }
    
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), ^(NSDictionary<NSString*, NSURL*>* urls) {
        BOOL errored = (urls == nil);
        if (completion_handler) {
            completion_handler(errored);
        }
        if (errored) {
            [controller showMessage:NSLocalizedString(@"app.player.stream_not_found_error.title", "") message:NSLocalizedString(@"app.player.stream_not_found_error.message", "") closeAfter:YES];
            return;
        }
        [controller configureWithQualities:urls preferred:PreferredQuality()];
    });
}

-(void)playWithURL:(NSURL*)url {
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:nil];
    [self showViewController:controller];
    [controller startWithURL:url];
}

-(void)playLocalURL:(NSURL*)url title:(NSString*)title {
    AniLotPlayerViewController* controller = [self makePlayerWithTitle:title];
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

@implementation DownloadItem

-(NSURL*)localURL {
    if (_relative_path.length == 0) {
        return nil;
    }
    return [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:_relative_path]];
}

-(NSDictionary*)toDictionary {
    return @{
        @"id": _identifier ?: @"",
        @"title": _title ?: @"",
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
    [self saveAndNotify];
    
    ResolveStreams(release_id, source_id, static_cast<int32_t>(position), ^(NSDictionary<NSString*, NSURL*>* urls) {
        if (!urls) {
            item.state = DownloadStateFailed;
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
    NSURLSessionTask* task = nil;
    if ([url.absoluteString.lowercaseString containsString:@".m3u8"]) {
        item.is_hls = YES;
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
        task = [_hls_session assetDownloadTaskWithURLAsset:asset assetTitle:item.title ?: @"AniLot" assetArtworkData:nil options:nil];
    } else {
        item.is_hls = NO;
        task = [_file_session downloadTaskWithURL:url];
    }
    if (!task) {
        item.state = DownloadStateFailed;
        [self saveAndNotify];
        return;
    }
    task.taskDescription = item.identifier;
    _tasks[item.identifier] = task;
    item.state = DownloadStateDownloading;
    [self saveAndNotify];
    [task resume];
}

-(void)deleteItem:(DownloadItem*)item {
    NSURLSessionTask* task = _tasks[item.identifier];
    [_tasks removeObjectForKey:item.identifier];
    [task cancel];
    NSURL* local = item.localURL;
    if (local) {
        [[NSFileManager defaultManager] removeItemAtURL:local error:nil];
    }
    [_mutable_items removeObject:item];
    [self saveAndNotify];
}

#pragma mark HLS (AVAssetDownloadDelegate)

-(void)URLSession:(NSURLSession*)session assetDownloadTask:(AVAssetDownloadTask*)task didLoadTimeRange:(CMTimeRange)time_range totalTimeRangesLoaded:(NSArray<NSValue*>*)loaded timeRangeExpectedToLoad:(CMTimeRange)expected {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item) {
        return;
    }
    double done = 0;
    for (NSValue* value in loaded) {
        done += CMTimeGetSeconds(value.CMTimeRangeValue.duration);
    }
    double total = CMTimeGetSeconds(expected.duration);
    item.progress = total > 0 ? MIN(1.0, done / total) : 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadManagerDidUpdateNotification object:self];
}

-(void)URLSession:(NSURLSession*)session assetDownloadTask:(AVAssetDownloadTask*)task didFinishDownloadingToURL:(NSURL*)location {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item) {
        return;
    }
    item.relative_path = location.relativePath;
    item.progress = 1.0;
}

#pragma mark Обычные файлы (NSURLSessionDownloadDelegate)

-(void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)task didWriteData:(int64_t)bytes totalBytesWritten:(int64_t)written totalBytesExpectedToWrite:(int64_t)expected {
    DownloadItem* item = [self itemWithIdentifier:task.taskDescription];
    if (!item) {
        return;
    }
    item.progress = expected > 0 ? (double)written / (double)expected : 0;
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
        item.relative_path = [@"Documents/Downloads" stringByAppendingPathComponent:destination.lastPathComponent];
        item.progress = 1.0;
    } else {
        item.state = DownloadStateFailed;
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
    if (error) {
        if (item.state != DownloadStateFailed) {
            item.state = DownloadStateFailed;
        }
    } else if (item.state != DownloadStateFailed && item.relative_path.length > 0) {
        item.state = DownloadStateCompleted;
        item.progress = 1.0;
    } else {
        item.state = DownloadStateFailed;
    }
    [self saveAndNotify];
}

@end
