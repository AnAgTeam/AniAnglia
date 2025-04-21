//
//  ProfilesTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfilesTableViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "ProfileViewController.h"

@interface ProfileTableViewCell ()
@property(nonatomic, retain) LoadableImageView* avatar_image;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* friend_count_label;
@property(nonatomic, retain) UIView* online_badge_view;

@end

@interface ProfilesTableViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching>
@property(nonatomic, retain) ProfilesPageableDataProvider* data_provider;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) UIView* header_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UILabel* empty_label;

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
    
    [self addSubview:_avatar_image];
    [self addSubview:_username_label];
    [self addSubview:_friend_count_label];
    
    _avatar_image.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _friend_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _online_badge_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_avatar_image.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_avatar_image.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_avatar_image.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_avatar_image.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_avatar_image.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_username_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_username_label.leadingAnchor constraintEqualToAnchor:_avatar_image.trailingAnchor constant:5],
        [_username_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_friend_count_label.topAnchor constraintEqualToAnchor:_username_label.bottomAnchor constant:5],
        [_friend_count_label.leadingAnchor constraintEqualToAnchor:_username_label.leadingAnchor],
        [_friend_count_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
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

@implementation ProfilesTableViewController

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = [[ProfilesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    [_data_provider loadCurrentPage];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    if (!_table_view) {
        _table_view = [UITableView new];
    }
    [_table_view registerClass:ProfileTableViewCell.class forCellReuseIdentifier:[ProfileTableViewCell getIdentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    _table_view.tableHeaderView = _header_view;
    
    _loadable_view = [LoadableView new];
    
    _empty_label = [UILabel new];
    _empty_label.text = NSLocalizedString(@"app.profiles.pages.empty", "");
    _empty_label.hidden = YES;
    
    [self.view addSubview:_table_view];
    [self.view addSubview:_loadable_view];
    [self.view addSubview:_empty_label];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    if (_is_container_view_controller) {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            
            [_empty_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor],
            [_empty_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor],
            [_empty_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor],
            [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [_empty_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
            
            [_empty_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_empty_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_empty_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
            [_empty_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
        ]];
    }

}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _empty_label.textColor = [AppColorProvider textColor];
}

-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}
-(void)reset {
    /* TODO: */
    [_data_provider reset];
    [_table_view reloadData];
}

-(void)reloadData {
    [_table_view reloadData];
}

-(void)setHeaderView:(UIView*)header_view {
    _header_view = header_view;
    if (_table_view) {
        _table_view.tableHeaderView = header_view;
    }
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_provider getItemsCount];
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 60;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    ProfileTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ProfileTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Profile::Ptr profile = [_data_provider getProfileAtIndex:index];
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(profile->avatar_url)];
    
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(profile->username)];
    [cell setIsOnline:profile->is_online];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if ([_data_provider isEnd]) {
        return;
    }
    NSUInteger item_count = [_table_view numberOfRowsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [_data_provider loadNextPage];
            return;
        }
    }
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::Profile::Ptr profile = [_data_provider getProfileAtIndex:index];
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:profile->id] animated:YES];
}

-(void)didUpdatedDataForProfilesPageableDataProvider:(ProfilesPageableDataProvider*)profiles_pageable_data_provider {
    [_table_view reloadData];
}

@end
