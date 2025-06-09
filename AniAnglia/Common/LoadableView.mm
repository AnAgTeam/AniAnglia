//
//  LoadableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.11.2024.
//

#import <Foundation/Foundation.h>
#import "LoadableView.h"
#import "AppColor.h"

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
            [_error_label.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
            [_error_label.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
            [_error_button.topAnchor constraintEqualToAnchor:_error_label.bottomAnchor constant:8],
            [_error_button.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
            [_error_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [_error_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        ]];
        
        [_error_label sizeToFit];
        [_error_button sizeToFit];
    }
}

-(void)startLoading {
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
