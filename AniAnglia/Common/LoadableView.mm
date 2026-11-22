//
//  LoadableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.11.2024.
//

#import <Foundation/Foundation.h>
#import "LoadableView.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface LoadableView ()
@property(nonatomic, retain) UIActivityIndicatorView* act_ind_view;

@property(nonatomic, retain) UILabel* error_label;
@property(nonatomic, retain) UIButton* error_button;
@end

@interface LoadableImageView ()
@property(nonatomic, retain) NSURLSessionTask* url_load_task;
@property(nonatomic, retain) LoadableView* loadable_view;
@end

@implementation LoadableView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _act_ind_view = [UIActivityIndicatorView new];
    
    _error_label = [UILabel new];
    _error_label.text = NSLocalizedString(@"app.loadable.error.text", "");
    
    _error_button = [UIButton new];
    [_error_button setTitle:NSLocalizedString(@"app.loadable.reload.title", "") forState:UIControlStateNormal];
    [_error_button addTarget:self action:@selector(onRetryPressed:) forControlEvents:UIControlEventTouchUpInside];
    _error_button.layer.cornerRadius = 8;
    _error_button.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    
    [self addSubview:_act_ind_view];
    
    _act_ind_view.translatesAutoresizingMaskIntoConstraints = NO;
    _error_label.translatesAutoresizingMaskIntoConstraints = NO;
    _error_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_act_ind_view.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_act_ind_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

-(void)setupLayout {
    _error_label.textColor = [AppColorProvider textColor];
    [_error_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _error_button.backgroundColor = [AppColorProvider primaryColor];
}

-(void)setErrorHidden:(BOOL)hidden {
    if (hidden) {
        [_error_label removeFromSuperview];
        [_error_button removeFromSuperview];
    } else {
        [self addSubview:_error_label];
        [self addSubview:_error_button];
        
        [NSLayoutConstraint activateConstraints:@[
            [_error_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
            [_error_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [_error_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
            [_error_label.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
            [_error_label.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
            
            [_error_button.topAnchor constraintEqualToAnchor:_error_label.bottomAnchor constant:10],
            [_error_button.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
            [_error_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [_error_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
            [_error_button.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        ]];
        
        [_error_label sizeToFit];
        [_error_button sizeToFit];
    }
}

-(void)startLoading {
    [self setErrored:NO];
    [_act_ind_view startAnimating];
}
-(void)endLoading {
    [self endLoadingWithErrored:NO];
}

-(void)endLoadingWithErrored:(BOOL)errored {
    [self setErrored:errored];
    [_act_ind_view stopAnimating];
}

-(void)setErrored:(BOOL)errored {
    [self setErrorHidden:!errored];
}

-(IBAction)onRetryPressed:(UIButton*)sender {
    [_delegate didReloadForLoadableView:self];
}

@end

@implementation LoadableImageView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    
    return self;
}

-(void)setup {
    _loadable_view = [LoadableView new];
    [self addSubview:_loadable_view];
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_loadable_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_loadable_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_loadable_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_loadable_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    self.image = nil;

}

+(NSCache<NSURL*, UIImage*>*)sharedImageCache {
    static NSCache* cache;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cache = [NSCache new];
        cache.countLimit = 300;
    });
    return cache;
}

+(NSURLCache*)sharedImageURLCache {
    static NSURLCache* cache;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSInteger limit = [[[AppDataController sharedInstance] getSettingsController] getMaxCacheSizeBytes];
        if (limit < 50 * 1024 * 1024) {
            limit = 250 * 1024 * 1024;
        }
        cache = [[NSURLCache alloc] initWithMemoryCapacity:32 * 1024 * 1024
                                              diskCapacity:(NSUInteger)limit
                                              directoryURL:nil];
    });
    return cache;
}

+(NSURLSession*)sharedImageSession {
    static NSURLSession* session;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURLSessionConfiguration* conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        conf.timeoutIntervalForRequest = 20;
        conf.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        conf.URLCache = [LoadableImageView sharedImageURLCache];
        conf.HTTPAdditionalHeaders = @{ @"Accept": @"image/webp,image/*,*/*;q=0.8" };
        session = [NSURLSession sessionWithConfiguration:conf];
    });
    return session;
}

+(NSUInteger)imageCacheDiskUsage {
    return [LoadableImageView sharedImageURLCache].currentDiskUsage;
}

+(void)setImageCacheDiskLimit:(NSUInteger)bytes {
    [LoadableImageView sharedImageURLCache].diskCapacity = bytes;
}

+(void)clearImageCache {
    [[LoadableImageView sharedImageCache] removeAllObjects];
    [[LoadableImageView sharedImageURLCache] removeAllCachedResponses];
}

-(void)tryLoadImageWithURL:(NSURL*)url {
    [self tryLoadImageWithURL:url attempt:0];
}

-(void)tryLoadImageWithURL:(NSURL*)url attempt:(int)attempt {
    if (_url_load_task) {
        [_url_load_task cancel];
        _url_load_task = nil;
    }
    self.image = nil;
    if (url == nil) {
        [_loadable_view endLoadingWithErrored:YES];
        return;
    }
    // ATS блокирует http://, поэтому поднимаем схему до https
    if ([url.scheme isEqualToString:@"http"]) {
        NSURLComponents* comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        comps.scheme = @"https";
        url = comps.URL ?: url;
    }
    UIImage* cached = [[LoadableImageView sharedImageCache] objectForKey:url];
    if (cached) {
        self.image = cached;
        [_loadable_view endLoading];
        return;
    }
    [_loadable_view startLoading];
    __weak LoadableImageView* weak_self = self;
    NSURLSessionDataTask* task = [[LoadableImageView sharedImageSession] dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error.code == NSURLErrorCancelled) {
            return;
        }
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 200;
        UIImage* image = (error == nil && data != nil && status < 400) ? [UIImage imageWithData:data] : nil;
        if (image) {
            // декодируем в фоне, чтобы не тормозила прокрутка
            UIGraphicsImageRenderer* r = [[UIGraphicsImageRenderer alloc] initWithSize:image.size];
            image = [r imageWithActions:^(UIGraphicsImageRendererContext* ctx) { [image drawAtPoint:CGPointZero]; }];
            [[LoadableImageView sharedImageCache] setObject:image forKey:url];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            LoadableImageView* strong_self = weak_self;
            if (!strong_self) return;
            if (image) {
                strong_self.image = image;
                [strong_self->_loadable_view endLoading];
            } else if (attempt < 2) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((attempt + 1) * 0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self tryLoadImageWithURL:url attempt:attempt + 1];
                });
            } else {
                [strong_self->_loadable_view endLoadingWithErrored:YES];
            }
        });
    }];
    _url_load_task = task;
    [task resume];
}

@end
