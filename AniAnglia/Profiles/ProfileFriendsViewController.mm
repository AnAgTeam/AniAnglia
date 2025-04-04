//
//  ProfileFriendsViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfileFriendsViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "ProfileViewController.h"

@interface FriendsTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* avatar_image;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* friend_count_label;

+(NSString*)getIndentifier;

-(void)setAvatarUrl:(NSURL*)url;
-(void)setUsername:(NSString*)username;
-(void)setFriendCount:(NSString*)friend_count;
@end

@interface ProfileFriendsViewController () <UITableViewDataSource, UITableViewDelegate> {
    anixart::ProfileID _profile_id;
    anixart::Pageable<anixart::Profile>::UPtr _pages;
    std::vector<anixart::Profile::Ptr> _profiles;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) UILabel* friends_label;
@property(nonatomic, retain) UITableView* friends_table_view;

@end

@implementation FriendsTableViewCell

+(NSString*)getIndentifier {
    return @"FriendsTableViewCell";
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
    
    [self addSubview:_avatar_image];
    [self addSubview:_username_label];
    [self addSubview:_friend_count_label];
    
    _avatar_image.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _friend_count_label.translatesAutoresizingMaskIntoConstraints = NO;
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
    _username_label.textColor = [AppColorProvider textColor];
    _friend_count_label.textColor = [AppColorProvider textSecondaryColor];
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

-(void)layoutSubviews {
    [super layoutSubviews];
    _avatar_image.layer.cornerRadius = _avatar_image.bounds.size.width / 2;
}

@end

@implementation ProfileFriendsViewController

-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _profile_id = profile_id;
    _pages = _api_proxy.api->profiles().get_friends(_profile_id, 0);
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    [self loadFirstPage];
}
-(void)setup {
    self.navigationItem.title = NSLocalizedString(@"app.profile_friends.title", "");
    
    _friends_label = [UILabel new];
    _friends_table_view = [UITableView new];
    [_friends_table_view registerClass:FriendsTableViewCell.class forCellReuseIdentifier:[FriendsTableViewCell getIndentifier]];
    _friends_table_view.dataSource = self;
    _friends_table_view.delegate = self;
    
    [self.view addSubview:_friends_label];
    [self.view addSubview:_friends_table_view];
    
    _friends_label.translatesAutoresizingMaskIntoConstraints = NO;
    _friends_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_friends_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_friends_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_friends_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_friends_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _friends_label.textColor = [AppColorProvider textColor];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _profiles.size();
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 80;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    FriendsTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[FriendsTableViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Profile::Ptr& profile = _profiles[index];
    
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(profile->avatar_url)];
    NSString* friend_count = [NSString stringWithFormat:@"%d %@", profile->friend_count, NSLocalizedString(@"app.profile_friends.friends_count.end", "")];
    
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(profile->username)];
    [cell setFriendCount:friend_count];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if (_pages->is_end()) {
        return;
    }
    NSUInteger item_count = [self tableView:_friends_table_view numberOfRowsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [self loadNextPage];
            return;
        }
    }
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::Profile::Ptr& profile = _profiles[index];
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:profile->id] animated:YES];
}

-(void)loadNextPage {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        std::vector<anixart::Profile::Ptr> profiles = self->_pages->next();
        self->_profiles.insert(self->_profiles.end(), profiles.begin(), profiles.end());
        return YES;
    } withUICompletion:^{
        [self->_friends_table_view reloadData];
    }];
}
-(void)loadFirstPage {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        self->_profiles = self->_pages->get();
        return YES;
    } withUICompletion:^{
        [self->_friends_table_view reloadData];
    }];
}
@end
