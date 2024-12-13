//
//  LoadableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.11.2024.
//

#import <Foundation/Foundation.h>
#import "LoadableView.h"

@interface LoadableView ()
@property(nonatomic, retain) UIActivityIndicatorView* act_ind_view;
@end

@interface LoadableImageView ()
@property(nonatomic, retain) NSURLSessionTask* url_load_task;
@property(nonatomic, retain) LoadableView* loadable_view;
@end

@implementation LoadableView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    
    return self;
}

-(void)setup {
    _act_ind_view = [UIActivityIndicatorView new];
    [self addSubview:_act_ind_view];
    _act_ind_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_act_ind_view.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_act_ind_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

-(void)startLoading {
    [_act_ind_view startAnimating];
}
-(void)endLoading {
    [_act_ind_view stopAnimating];
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

-(void)tryLoadImageWithURL:(NSURL*)url {
    self.image = nil;
    if (_url_load_task) {
        [_url_load_task cancel];
    }
    [_loadable_view startLoading];
    _url_load_task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data == nil) {
            // error
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [UIImage imageWithData:data];
            self.image = image;
            [self->_loadable_view endLoading];
        });
    }];
    [_url_load_task resume];
}

@end
