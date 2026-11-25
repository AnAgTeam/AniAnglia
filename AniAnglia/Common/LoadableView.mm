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

@interface LoadableImageRequest ()
-(instancetype)initWithCompletion:(void(^)(UIImage* image))completion;
-(void)setTask:(NSURLSessionTask*)task;
-(BOOL)isCancelled;
-(void)finishWithImage:(UIImage*)image;
@end

@interface LoadableImageView () <LoadableViewDelegate>
@property(nonatomic, retain) LoadableImageRequest* image_request;
@property(nonatomic, retain) NSURL* current_url;
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

#pragma mark - Загрузчик изображений (https-апгрейд + прокси-fallback + альтернативное соединение)

static NSString* const kPreferProxyKey = @"anilot_images_prefer_proxy";
static BOOL gPreferProxy = NO;
static int gDirectFailures = 0;

static void LoadPreferProxyOnce(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        gPreferProxy = [[NSUserDefaults standardUserDefaults] boolForKey:kPreferProxyKey];
    });
}

static void NoteDirectResult(BOOL success) {
    if (success) {
        gDirectFailures = 0;
        return;
    }
    gDirectFailures++;
    if (gDirectFailures >= 2 && !gPreferProxy) {
        gPreferProxy = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreferProxyKey];
    }
}

static UIImage* PrepareImage(UIImage* image) {
    // декодируем в фоновом потоке, чтобы не тормозила прокрутка
    UIImage* prepared = [image imageByPreparingForDisplay];
    return prepared ?: image;
}

@implementation LoadableImageRequest {
    NSURLSessionTask* _task;
    BOOL _cancelled;
    void (^_completion)(UIImage* image);
}

-(instancetype)initWithCompletion:(void(^)(UIImage* image))completion {
    self = [super init];
    _completion = [completion copy];
    return self;
}

-(void)setTask:(NSURLSessionTask*)task {
    @synchronized (self) {
        _task = task;
    }
}

-(BOOL)isCancelled {
    @synchronized (self) {
        return _cancelled;
    }
}

-(void)cancel {
    NSURLSessionTask* task = nil;
    @synchronized (self) {
        _cancelled = YES;
        task = _task;
        _task = nil;
        _completion = nil;
    }
    [task cancel];
}

/* вызывается на главной очереди */
-(void)finishWithImage:(UIImage*)image {
    void (^completion)(UIImage*) = nil;
    @synchronized (self) {
        if (_cancelled) {
            return;
        }
        completion = _completion;
        _completion = nil;
        _task = nil;
    }
    if (completion) {
        completion(image);
    }
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
    _loadable_view.delegate = self;
    [self addSubview:_loadable_view];
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_loadable_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_loadable_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_loadable_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_loadable_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    self.image = nil;
}

+(NSCache<NSString*, UIImage*>*)sharedImageCache {
    static NSCache* cache;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cache = [NSCache new];
        cache.countLimit = 300;
        cache.totalCostLimit = 160 * 1024 * 1024;
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
        conf.timeoutIntervalForRequest = 40;
        conf.HTTPMaximumConnectionsPerHost = 12;
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

/* ATS блокирует http://, поэтому поднимаем схему до https (в том числе для //host/path) */
+(NSURL*)secureURLForURL:(NSURL*)url {
    if (url == nil) {
        return nil;
    }
    NSString* scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"https"]) {
        return url;
    }
    if (scheme.length == 0 || [scheme isEqualToString:@"http"]) {
        NSURLComponents* comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        if (comps.host.length == 0) {
            return url;
        }
        comps.scheme = @"https";
        return comps.URL ?: url;
    }
    return url;
}

+(NSURL*)proxyURLForURL:(NSURL*)url fullSize:(BOOL)full_size {
    NSMutableCharacterSet* allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:@"-._~"];
    NSString* encoded = [url.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSString* prefix = full_size ? @"https://wsrv.nl/?we&w=2400&q=90&url=" : @"https://wsrv.nl/?we&w=600&q=80&url=";
    return [NSURL URLWithString:[prefix stringByAppendingString:encoded ?: @""]];
}

+(NSURL*)proxyURLForURL:(NSURL*)url {
    return [self proxyURLForURL:url fullSize:NO];
}

+(void)performLoadForRequest:(LoadableImageRequest*)request url:(NSURL*)url fullSize:(BOOL)full_size attempt:(int)attempt {
    if ([request isCancelled]) {
        return;
    }
    // Порядок попыток: прямой запрос и запасной путь через прокси-кэш картинок.
    // При включённом «альтернативном соединении» сначала идёт прокси (когда CDN заблокирован).
    LoadPreferProxyOnce();
    BOOL proxy_first = gPreferProxy || [[[AppDataController sharedInstance] getSettingsController] getAlternativeConnection];
    BOOL use_proxy = proxy_first ? (attempt % 2 == 0) : (attempt % 2 == 1);
    NSURL* request_url = use_proxy ? ([LoadableImageView proxyURLForURL:url fullSize:full_size] ?: url) : url;
    NSMutableURLRequest* url_request = [NSMutableURLRequest requestWithURL:request_url];
    // прямой путь при блокировке не должен висеть долго
    url_request.timeoutInterval = use_proxy ? (full_size ? 40 : 25) : (full_size ? 15 : 7);
    NSString* cache_key = [LoadableImageView cacheKeyForURL:url fullSize:full_size];
    
    NSURLSessionDataTask* task = [[LoadableImageView sharedImageSession] dataTaskWithRequest:url_request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error.code == NSURLErrorCancelled || [request isCancelled]) {
            return;
        }
        NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse*)response).statusCode : 200;
        UIImage* image = (error == nil && data.length > 0 && status < 400) ? [UIImage imageWithData:data] : nil;
        if (!use_proxy) {
            NoteDirectResult(image != nil);
        }
        if (image) {
            image = PrepareImage(image);
            NSUInteger cost = (NSUInteger)(image.size.width * image.scale * image.size.height * image.scale * 4);
            [[LoadableImageView sharedImageCache] setObject:image forKey:cache_key cost:cost];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([request isCancelled]) {
                return;
            }
            if (image) {
                [request finishWithImage:image];
            } else if (attempt < 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [LoadableImageView performLoadForRequest:request url:url fullSize:full_size attempt:attempt + 1];
                });
            } else {
                [request finishWithImage:nil];
            }
        });
    }];
    [request setTask:task];
    [task resume];
}

+(NSString*)cacheKeyForURL:(NSURL*)url fullSize:(BOOL)full_size {
    return full_size ? [url.absoluteString stringByAppendingString:@"#full"] : url.absoluteString;
}

+(LoadableImageRequest*)loadImageWithURL:(NSURL*)url fullSize:(BOOL)full_size completion:(void(^)(UIImage* image))completion {
    LoadableImageRequest* request = [[LoadableImageRequest alloc] initWithCompletion:completion];
    NSURL* secure = [LoadableImageView secureURLForURL:url];
    if (secure == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [request finishWithImage:nil];
        });
        return request;
    }
    UIImage* cached = [[LoadableImageView sharedImageCache] objectForKey:[LoadableImageView cacheKeyForURL:secure fullSize:full_size]];
    if (cached) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [request finishWithImage:cached];
        });
        return request;
    }
    [LoadableImageView performLoadForRequest:request url:secure fullSize:full_size attempt:0];
    return request;
}

-(void)tryLoadImageWithURL:(NSURL*)url {
    [_image_request cancel];
    _image_request = nil;
    _current_url = url;
    self.image = nil;
    if (url == nil) {
        [_loadable_view endLoadingWithErrored:YES];
        return;
    }
    NSURL* secure = [LoadableImageView secureURLForURL:url];
    UIImage* cached = [[LoadableImageView sharedImageCache] objectForKey:[LoadableImageView cacheKeyForURL:secure fullSize:NO]];
    if (cached) {
        self.image = cached;
        [_loadable_view endLoading];
        return;
    }
    [_loadable_view startLoading];
    
    __weak LoadableImageView* weak_self = self;
    _image_request = [LoadableImageView loadImageWithURL:url fullSize:NO completion:^(UIImage* image) {
        LoadableImageView* strong_self = weak_self;
        if (!strong_self) {
            return;
        }
        strong_self.image_request = nil;
        if (image) {
            strong_self.image = image;
            [strong_self->_loadable_view endLoading];
        } else {
            [strong_self->_loadable_view endLoadingWithErrored:YES];
        }
    }];
}

// кнопка «Повторить» в состоянии ошибки
-(void)didReloadForLoadableView:(LoadableView*)loadable_view {
    [self tryLoadImageWithURL:_current_url];
}

@end
