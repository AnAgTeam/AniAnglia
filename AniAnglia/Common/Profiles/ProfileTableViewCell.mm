//
//  ProfileTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#import <Foundation/Foundation.h>
#import "ProfileTableViewCell.h"
#import "LoadableView.h"
#import "AppColor.h"

@interface ProfileTableViewCell ()
@property(nonatomic, retain) LoadableImageView* avatar_image;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* friend_count_label;
@property(nonatomic, retain) UIView* online_badge_view;

@end

@implementation ProfileTableViewCell

+(NSString*)getIdentifier {
    return @"ProfileTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _avatar_image = [LoadableImageView new];
    _avatar_image.clipsToBounds = YES;
    
    _username_label = [UILabel new];
    
    _friend_count_label = [UILabel new];
    
    _online_badge_view = [UIView new];
    
    [self.contentView addSubview:_avatar_image];
    [self.contentView addSubview:_username_label];
    [self.contentView addSubview:_friend_count_label];
    
    _avatar_image.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _friend_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _online_badge_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_avatar_image.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_avatar_image.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_avatar_image.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor],
        [_avatar_image.widthAnchor constraintEqualToAnchor:_avatar_image.heightAnchor],
        [_avatar_image.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_username_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_username_label.leadingAnchor constraintEqualToAnchor:_avatar_image.trailingAnchor constant:10],
        [_username_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        
        [_friend_count_label.topAnchor constraintEqualToAnchor:_username_label.bottomAnchor constant:5],
        [_friend_count_label.leadingAnchor constraintEqualToAnchor:_username_label.leadingAnchor],
        [_friend_count_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_friend_count_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
    ]];
}

-(void)setupLayout {
    _avatar_image.backgroundColor = [AppColorProvider foregroundColor1];
    _username_label.textColor = [AppColorProvider textColor];
    _friend_count_label.textColor = [AppColorProvider textSecondaryColor];
    _online_badge_view.backgroundColor = [UIColor clearColor];
}

-(void)setAvatarUrl:(NSURL*)url {
    [_avatar_image tryLoadImageWithURL:url];
}
-(void)setUsername:(NSString*)username {
    _username_label.text = username;
}
-(void)setFriendCount:(NSString*)friend_count {
    _friend_count_label.text = friend_count;
}
-(void)setIsOnline:(BOOL)is_online {
    _online_badge_view.backgroundColor = is_online ? [UIColor systemGreenColor] : [UIColor clearColor];
}

-(void)applyConstraintsToOnlineBadge {
    CGFloat radians = -45 * (M_PI / 180);

    CGFloat xmult = (1 + cos(radians)) / 2;
    CGFloat ymult = (1 - sin(radians)) / 2;
    
    [_online_badge_view removeFromSuperview];
    [self.contentView addSubview:_online_badge_view];
    
    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:_online_badge_view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_avatar_image attribute:NSLayoutAttributeTrailing multiplier:xmult constant:0],
        [NSLayoutConstraint constraintWithItem:_online_badge_view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_avatar_image attribute:NSLayoutAttributeBottom multiplier:ymult constant:0],
        
        [_online_badge_view.heightAnchor constraintEqualToConstant:15],
        [_online_badge_view.widthAnchor constraintEqualToConstant:15],
    ]];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _avatar_image.layer.cornerRadius = _avatar_image.bounds.size.width / 2;
    
    [self applyConstraintsToOnlineBadge];
    _online_badge_view.layer.cornerRadius = _online_badge_view.bounds.size.width / 2;
}

@end
