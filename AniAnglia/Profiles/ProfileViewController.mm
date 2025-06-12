//
//  ProfileViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "ProfileViewController.h"
#import "AppColor.h"
#import "LoadableView.h"
#import "LibanixartApi.h"
#import "AppDataController.h"
#import "StringCvt.h"
#import "TimeCvt.h"
#import "ProfileListsView.h"
#import "DynamicTableView.h"
#import "ProfileFriendsViewController.h"
#import "ReleaseViewController.h"
#import "SharedRunningData.h"
#import "CommentsTableViewController.h"
#import "SegmentedPageViewController.h"
#import "CommentRepliesViewController.h"
#import "CollectionsCollectionViewController.h"
#import "ReleasesTableViewController.h"
#import "NamedSectionView.h"
#import "ReleasesHistoryTableViewController.h"
#import "CenteredCollectionViewFlowLayout.h"
#import "ReleasesVotesTableViewController.h"
#import "ReleasesViewController.h"

@class ProfileStatsBlockView;
@class ProfileActionsView;

@protocol ProfileStatsBlockViewDelegate <NSObject>
-(void)didCommentsPressedForProfileStatsBlockView:(ProfileStatsBlockView*)profile_stats_block_view;
-(void)didVideosPressedForProfileStatsBlockView:(ProfileStatsBlockView*)profile_stats_block_view;
-(void)didCollectionsPressedForProfileStatsBlockView:(ProfileStatsBlockView*)profile_stats_block_view;
-(void)didFriendsPressedForProfileStatsBlockView:(ProfileStatsBlockView*)profile_stats_block_view;
@end

@protocol ProfileActionViewDelegate <NSObject>
-(void)didEditPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didMessagePressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didAddToFriendsPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didRemoveFromFriendsPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didCancelFriendRequestPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didAcceptFriendRequestPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
-(void)didRejectFriendRequestPressedForProfileActionsView:(ProfileActionsView*)profile_actions_view;
@end

@interface ProfileStatsButton : UIButton
@property(nonatomic, retain, readonly) NSString* name;
@property(nonatomic, readonly) NSInteger count;
@property(nonatomic, retain) UILabel* count_label;
@property(nonatomic, retain) UILabel* name_label;

-(instancetype)initWithName:(NSString*)name count:(NSInteger)count;
-(void)setCount:(NSInteger)count;
@end

@interface ProfileStatsBlockView : UIView {
    anixart::Profile::Ptr _profile;
}
@property(nonatomic, weak) id<ProfileStatsBlockViewDelegate> delegate;
@property(nonatomic, retain) UIStackView* stats_stack_view;
@property(nonatomic, retain) ProfileStatsButton* comment_count_stat_button;
@property(nonatomic, retain) ProfileStatsButton* video_count_stat_button;
@property(nonatomic, retain) ProfileStatsButton* collection_count_stat_button;
@property(nonatomic, retain) ProfileStatsButton* friend_count_stat_button;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
@end

@interface ProfileRolesViewCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) UILabel* name_label;

+(NSString*)getIdentifier;

-(void)setColor:(UIColor*)color;
-(void)setName:(NSString*)name;

@end

@interface ProfileRolesView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    anixart::Profile::Ptr _profile;
}
@property(nonatomic, retain) UICollectionView* roles_collection_view;
@property(nonatomic) CGFloat cell_max_x;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;
@end

@interface ProfileActionsView : UIView {
    anixart::Profile::Ptr _profile;
    bool _is_my_profile;
    anixart::Profile::FriendStatus _friend_status;
}
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, weak) id<ProfileActionViewDelegate> delegate;
@property(nonatomic, retain, readonly) NSArray<UIButton*>* action_buttons;
@property(nonatomic, retain) UIStackView* actions_stack_view;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile isMyProfile:(BOOL)is_my_profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
-(void)updateActions;
@end

@interface ReleasesVotesViewController : ReleasesViewController

@end

@interface ProfileWatchDynamicsViewCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) UILabel* count_label;
@property(nonatomic, retain) UIView* indicator_container_view;
@property(nonatomic, retain) UIView* indicator_wrapper_view;
@property(nonatomic, retain) UIView* indicator_view;
@property(nonatomic, retain) UILabel* time_label;
@property(nonatomic, retain) NSLayoutConstraint* indicator_height_constraint;

+(NSString*)getIdentifier;

-(void)setCount:(NSInteger)count totalCount:(NSInteger)total_count;
-(void)setTime:(NSString*)time;
@end

@interface ProfileWatchDynamicsView : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {
    anixart::Profile::Ptr _profile;
    int64_t _max_dynamic_count;
}
@property(nonatomic, retain) UICollectionView* dynamics_collection_view;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
@end

@interface ProfileViewController () <ProfileStatsBlockViewDelegate, ProfileActionViewDelegate, CommentsTableViewControllerDelegate, LoadableViewDelegate> {
    anixart::ProfileID _profile_id;
    anixart::Profile::Ptr _profile;
    bool _is_my_profile;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, retain) LoadableView* loading_view;
@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) UIStackView* content_stack_view;

@property(nonatomic, retain) LoadableImageView* avatar_image_view;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* custom_status_label;
@property(nonatomic, retain) ProfileRolesView* roles_view;
@property(nonatomic, retain) UILabel* status_label;
@property(nonatomic, retain) UIButton* action_button;

@property(nonatomic, retain) NSMutableArray<NamedSectionView*>* named_sections;
@property(nonatomic, retain) ProfileStatsBlockView* stats_view;
@property(nonatomic, retain) ProfileActionsView* actions_view;
@property(nonatomic, retain) ProfileListsView* lists_view;
@property(nonatomic, retain) ReleasesVotesTableViewController* votes_view_controller;
@property(nonatomic, retain) ProfileWatchDynamicsView* watch_dynamics_view;
@property(nonatomic, retain) ReleasesHistoryTableViewController* watched_recently_view_controller;


@end

@implementation ProfileStatsButton

-(instancetype)initWithName:(NSString*)name count:(NSInteger)count {
    self = [super init];
    
    _count = count;
    _name = name;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _count_label = [UILabel new];
    _count_label.text = [@(_count) stringValue];
    _count_label.textAlignment = NSTextAlignmentCenter;
    _count_label.userInteractionEnabled = NO;
    _name_label = [UILabel new];
    _name_label.text = _name;
    _name_label.textAlignment = NSTextAlignmentCenter;
    _name_label.userInteractionEnabled = NO;
    _name_label.font = [UIFont systemFontOfSize:14];
    
    [self addSubview:_count_label];
    [self addSubview:_name_label];
    
    _count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_count_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_count_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_count_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_name_label.topAnchor constraintEqualToAnchor:_count_label.bottomAnchor constant:5],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_name_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_name_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_count_label sizeToFit];
    [_name_label sizeToFit];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _count_label.textColor = [AppColorProvider textColor];
    _name_label.textColor = [AppColorProvider textSecondaryColor];
}
-(void)setCount:(NSInteger)count {
    _count_label.text = [@(count) stringValue];
    [_count_label sizeToFit];
}
@end

@implementation ProfileStatsBlockView

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _profile = profile;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _stats_stack_view = [UIStackView new];
    _stats_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _stats_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _stats_stack_view.alignment = UIStackViewAlignmentFill;
    
    _comment_count_stat_button = [[ProfileStatsButton alloc] initWithName:NSLocalizedString(@"app.profile.stats_block.comment_count.name", "") count:_profile->comment_count];
    [_comment_count_stat_button addTarget:self action:@selector(onCommentsStatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _comment_count_stat_button.layer.cornerRadius = 8;
    
    _video_count_stat_button = [[ProfileStatsButton alloc] initWithName:NSLocalizedString(@"app.profile.stats_block.video_count.name", "") count:_profile->video_count];
    [_video_count_stat_button addTarget:self action:@selector(onVideosStatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _video_count_stat_button.layer.cornerRadius = 8;
    
    _collection_count_stat_button = [[ProfileStatsButton alloc] initWithName:NSLocalizedString(@"app.profile.stats_block.collection_count.name", "") count:_profile->collection_count];
    [_collection_count_stat_button addTarget:self action:@selector(onCollectionsStatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _collection_count_stat_button.layer.cornerRadius = 8;
    
    _friend_count_stat_button = [[ProfileStatsButton alloc] initWithName:NSLocalizedString(@"app.profile.stats_block.friend_count.name", "") count:_profile->friend_count];
    [_friend_count_stat_button addTarget:self action:@selector(onFriendsStatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _friend_count_stat_button.layer.cornerRadius = 8;
    
    [self addSubview:_stats_stack_view];
    [_stats_stack_view addArrangedSubview:_comment_count_stat_button];
    [_stats_stack_view addArrangedSubview:_video_count_stat_button];
    [_stats_stack_view addArrangedSubview:_collection_count_stat_button];
    [_stats_stack_view addArrangedSubview:_friend_count_stat_button];
    
    _stats_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_stats_stack_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_stats_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_stats_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_stats_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {

}

-(void)setProfile:(anixart::Profile::Ptr)profile {
    _profile = profile;
    
    [_comment_count_stat_button setCount:_profile->comment_count];
    [_video_count_stat_button setCount:_profile->video_count];
    [_collection_count_stat_button setCount:_profile->collection_count];
    [_friend_count_stat_button setCount:_profile->friend_count];
}

-(IBAction)onCommentsStatButtonPressed:(UIButton*)sender {
    [_delegate didCommentsPressedForProfileStatsBlockView:self];
}
-(IBAction)onVideosStatButtonPressed:(UIButton*)sender {
    [_delegate didVideosPressedForProfileStatsBlockView:self];
}
-(IBAction)onCollectionsStatButtonPressed:(UIButton*)sender {
    [_delegate didCollectionsPressedForProfileStatsBlockView:self];
}
-(IBAction)onFriendsStatButtonPressed:(UIButton*)sender {
    [_delegate didFriendsPressedForProfileStatsBlockView:self];
}
@end

@implementation ProfileRolesViewCollectionViewCell

+(NSString*)getIdentifier {
    return @"ProfileRolesViewCollectionViewCell";
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 8;
    
    _name_label = [UILabel new];
    
    [self.contentView addSubview:_name_label];
    
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_name_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_name_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_name_label.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor],
        [_name_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    
}

-(void)setColor:(UIColor*)color {
    self.contentView.backgroundColor = color;
}
-(void)setName:(NSString*)name {
    _name_label.text = name;
}

-(UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layout_attributes {
    UICollectionViewLayoutAttributes* attributes = [super preferredLayoutAttributesFittingAttributes:layout_attributes];
    return attributes;
}

@end

@implementation ProfileRolesView

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _profile = profile;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    CenteredCollectionViewFlowLayout* layout = [CenteredCollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
//    layout.itemSize = UICollectionViewFlowLayoutAutomaticSize;
    _roles_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_roles_collection_view registerClass:ProfileRolesViewCollectionViewCell.class forCellWithReuseIdentifier:[ProfileRolesViewCollectionViewCell getIdentifier]];
    _roles_collection_view.dataSource = self;
    _roles_collection_view.delegate = self;
    
    [self addSubview:_roles_collection_view];
    
    _roles_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_roles_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_roles_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_roles_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_roles_collection_view.heightAnchor constraintGreaterThanOrEqualToConstant:40],
        [_roles_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    
}

-(UIColor*)getRoleColorFromHEX:(NSString*)hex_color_string {
    NSScanner* scanner = [NSScanner scannerWithString:hex_color_string];
    uint64_t hex_color;
    if (![scanner scanHexLongLong:&hex_color]) {
        return nil;
    }
    
    int red = (hex_color >> 16) & 0xFF;
    int green = (hex_color >> 8) & 0xFF;
    int blue = hex_color & 0xFF;
    return [UIColor colorWithRed:(red / 255.) green:(green / 255.) blue:(blue / 255.) alpha:1.0];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collection_view numberOfItemsInSection:(NSInteger)section {
    return _profile->roles.size();
}

// this prevents warnings about cells size
-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.bounds.size.width, collection_view.bounds.size.height);
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ProfileRolesViewCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ProfileRolesViewCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = index_path.row;
    anixart::Role::Ptr& role = _profile->roles[index];
    
    [cell setColor:[self getRoleColorFromHEX:TO_NSSTRING(role->color)]];
    [cell setName:TO_NSSTRING(role->name)];
    
    return cell;
}

@end

@implementation ProfileActionsView

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile isMyProfile:(BOOL)is_my_profile {
    self = [super init];
    
    _app_data_controller = [AppDataController sharedInstance];
    _is_my_profile = is_my_profile;
    _profile = profile;
    _friend_status = _profile->get_friend_status_to([_app_data_controller getMyProfileID]);
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _actions_stack_view = [UIStackView new];
    _actions_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _actions_stack_view.distribution = UIStackViewDistributionFillEqually;
    _actions_stack_view.alignment = UIStackViewAlignmentFill;
    _actions_stack_view.spacing = 8;
    
    [self addSubview:_actions_stack_view];
    [self updateActions];
    
    _actions_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_actions_stack_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_actions_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_actions_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_actions_stack_view.heightAnchor constraintEqualToConstant:50],
        [_actions_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    [self setupActionsLayout];
}
-(void)setupActionsLayout {
    for (UIButton* button : _action_buttons) {
        button.backgroundColor = [AppColorProvider primaryColor];
    }
}

-(NSArray<UIButton*>*)makeActionButtons {
    if (_friend_status == anixart::Profile::FriendStatus::NotFriends) {
        UIButton* add_to_friends_button = [UIButton new];
        [add_to_friends_button setTitle:NSLocalizedString(@"app.profile.actions.add_to_friends_button.title", "") forState:UIControlStateNormal];
        [add_to_friends_button addTarget:self action:@selector(onAddToFriendsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        add_to_friends_button.layer.cornerRadius = 8.0;
        return @[add_to_friends_button];
    }
    else if (_friend_status == anixart::Profile::FriendStatus::Friends) {
        // TODO: add message button. Maybe useless button? ;)
        UIButton* remove_from_friends_button = [UIButton new];
        [remove_from_friends_button setTitle:NSLocalizedString(@"app.profile.actions.remove_from_friends.title", "") forState:UIControlStateNormal];
        [remove_from_friends_button addTarget:self action:@selector(onRemoveFromFriendsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        remove_from_friends_button.layer.cornerRadius = 8.0;
        return @[remove_from_friends_button];
    }
    else if (_friend_status == anixart::Profile::FriendStatus::SendedRequest) {
        UIButton* cancel_friend_request_button = [UIButton new];
        [cancel_friend_request_button setTitle:NSLocalizedString(@"app.profile.actions.cancel_friend_request_button.title", "") forState:UIControlStateNormal];
        [cancel_friend_request_button addTarget:self action:@selector(onCancelFriendRequestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cancel_friend_request_button.layer.cornerRadius = 8.0;
        return @[cancel_friend_request_button];
    }
    else if (_friend_status == anixart::Profile::FriendStatus::RecievedRequest) {
        UIButton* accept_friend_request_button = [UIButton new];
        [accept_friend_request_button setTitle:NSLocalizedString(@"app.profile.actions.accept_friend_request_button.title", "") forState:UIControlStateNormal];
        [accept_friend_request_button addTarget:self action:@selector(onAcceptFriendRequestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        accept_friend_request_button.layer.cornerRadius = 8.0;
        UIButton* reject_friend_request_button = [UIButton new];
        [reject_friend_request_button setTitle:NSLocalizedString(@"app.profile.actions.reject_friend_request_button.title", "") forState:UIControlStateNormal];
        [reject_friend_request_button addTarget:self action:@selector(onRejectFriendRequestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        reject_friend_request_button.layer.cornerRadius = 8.0;
        return @[accept_friend_request_button, reject_friend_request_button];
    }
    return @[];
}

-(void)setProfile:(anixart::Profile::Ptr)profile {
    _profile = profile;
    [self setFriendStatus:_profile->get_friend_status_to([_app_data_controller getMyProfileID])];
}
-(void)setFriendStatus:(anixart::Profile::FriendStatus)friend_status {
    // TODO: just update buttons title and action
    _friend_status = friend_status;
    [self updateActions];
}
-(void)updateActions {
    if (_action_buttons) {
        for (UIButton* button : _action_buttons) {
            [button removeFromSuperview];
            [_actions_stack_view removeArrangedSubview:button];
        }
    }
    _action_buttons = [self makeActionButtons];
    for (UIButton* button : _action_buttons) {
        [_actions_stack_view addArrangedSubview:button];
    }
    [self setupActionsLayout];
}

-(IBAction)onEditButtonPressed:(UIButton*)sender {
    [_delegate didEditPressedForProfileActionsView:self];
}
-(IBAction)onAddToFriendsButtonPressed:(UIButton*)sender {
    [_delegate didAddToFriendsPressedForProfileActionsView:self];
}
-(IBAction)onRemoveFromFriendsButtonPressed:(UIButton*)sender {
    [_delegate didRemoveFromFriendsPressedForProfileActionsView:self];
}
-(IBAction)onCancelFriendRequestButtonPressed:(UIButton*)sender {
    [_delegate didCancelFriendRequestPressedForProfileActionsView:self];
}
-(IBAction)onAcceptFriendRequestButtonPressed:(UIButton*)sender {
    [_delegate didAcceptFriendRequestPressedForProfileActionsView:self];
}
-(IBAction)onRejectFriendRequestButtonPressed:(UIButton*)sender {
    [_delegate didRejectFriendRequestPressedForProfileActionsView:self];
}
@end

@implementation ReleasesVotesViewController

-(UIViewController<PageableDataProviderDelegate>*)getTableViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider {
    return [[ReleasesVotesTableViewController alloc] initWithTableView:[UITableView new] releasesPageableDataProvider:data_provider];
}

@end

@implementation ProfileWatchDynamicsViewCollectionViewCell

static const NSInteger PROFILE_WATCH_DYNAMICS_CELL_TIME_LABEL_HEIGHT = 30;
static const NSInteger PROFILE_WATCH_DYNAMICS_CELL_COUNT_LABEL_HEIGHT = 30;

+(NSString*)getIdentifier {
    return @"ProfileWatchDynamicsViewCollectionViewCell";
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _count_label = [UILabel new];
    _count_label.textAlignment = NSTextAlignmentCenter;
    
    _indicator_container_view = [UIView new];
    _indicator_container_view.clipsToBounds = YES;

    _indicator_view = [UIView new];
    _indicator_view.layer.cornerRadius = 8;
    _indicator_view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    _time_label = [UILabel new];
    _time_label.font = [UIFont systemFontOfSize:12];
    _time_label.transform = CGAffineTransformMakeRotation(-70 * (M_PI / 180));
    
    [self addSubview:_indicator_container_view];
    [self addSubview:_time_label];
    [self addSubview:_count_label];
    [_indicator_container_view addSubview:_indicator_view];
    
    _count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _indicator_container_view.translatesAutoresizingMaskIntoConstraints = NO;
    _indicator_wrapper_view.translatesAutoresizingMaskIntoConstraints = NO;
    _indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _time_label.translatesAutoresizingMaskIntoConstraints = NO;
    _indicator_height_constraint = nil;
    [NSLayoutConstraint activateConstraints:@[
        [_indicator_container_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor constant:(PROFILE_WATCH_DYNAMICS_CELL_COUNT_LABEL_HEIGHT + 5)], // + offset
        [_indicator_container_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_indicator_container_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_indicator_container_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor constant:-(PROFILE_WATCH_DYNAMICS_CELL_COUNT_LABEL_HEIGHT + 10)], // + top and bottom offset
        
        [_count_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_count_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_count_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_count_label.bottomAnchor constraintEqualToAnchor:_indicator_view.topAnchor constant:-5],
        
        [_indicator_view.topAnchor constraintGreaterThanOrEqualToAnchor:_indicator_container_view.topAnchor],
        [_indicator_view.leadingAnchor constraintEqualToAnchor:_indicator_container_view.leadingAnchor],
        [_indicator_view.trailingAnchor constraintEqualToAnchor:_indicator_container_view.trailingAnchor],
        [_indicator_view.bottomAnchor constraintEqualToAnchor:_indicator_container_view.bottomAnchor],
        
        [_time_label.topAnchor constraintEqualToAnchor:_indicator_container_view.bottomAnchor constant:5],
        [_time_label.heightAnchor constraintEqualToConstant:PROFILE_WATCH_DYNAMICS_CELL_TIME_LABEL_HEIGHT],
        [_time_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor constant:-5]
    ]];
}
-(void)setupLayout {
    _count_label.textColor = [AppColorProvider textColor];
    _indicator_view.backgroundColor = [AppColorProvider primaryColor];
    _time_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setCount:(NSInteger)count totalCount:(NSInteger)total_count {
    if (_indicator_height_constraint) {
        _indicator_height_constraint.active = NO;
    }
    _indicator_height_constraint = [_indicator_view.heightAnchor constraintEqualToAnchor:_indicator_container_view.heightAnchor multiplier:(static_cast<double>(count) / MAX(total_count, 1))];
    _indicator_height_constraint.active = YES;
    
    _count_label.text = [@(count) stringValue];
}
-(void)setTime:(NSString*)time {
    _time_label.text = time;
    [_time_label sizeToFit];
}

@end

@implementation ProfileWatchDynamicsView

static size_t PROFILE_WATCH_DYNAMICS_COLLECTION_VIEW_HEIGHT = 200;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _profile = profile;
    [self setup];
    [self setupLayout];
    [self calcMaxDynamicCount];
    
    return self;
}

-(void)setup {
    UICollectionViewFlowLayout* dynamics_collection_layout = [UICollectionViewFlowLayout new];
    dynamics_collection_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _dynamics_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:dynamics_collection_layout];
    [_dynamics_collection_view registerClass:ProfileWatchDynamicsViewCollectionViewCell.class forCellWithReuseIdentifier:[ProfileWatchDynamicsViewCollectionViewCell getIdentifier]];
    _dynamics_collection_view.dataSource = self;
    _dynamics_collection_view.delegate = self;
    _dynamics_collection_view.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    
    [self addSubview:_dynamics_collection_view];
    
    _dynamics_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_dynamics_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_dynamics_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_dynamics_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_dynamics_collection_view.heightAnchor constraintEqualToConstant:PROFILE_WATCH_DYNAMICS_COLLECTION_VIEW_HEIGHT],
        [_dynamics_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    
}

-(void)calcMaxDynamicCount {
    _max_dynamic_count = 0;
    for (anixart::ProfileWatchDynamic::Ptr watch_dynamic : _profile->watch_dynamics) {
        _max_dynamic_count = MAX(_max_dynamic_count, watch_dynamic->watched_count);
    }
}

-(void)setProfile:(anixart::Profile::Ptr)profile {
    _profile = profile;
    [self calcMaxDynamicCount];
    [_dynamics_collection_view reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collection_view numberOfItemsInSection:(NSInteger)section {
    return _profile->watch_dynamics.size();
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collection_view layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ProfileWatchDynamicsViewCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ProfileWatchDynamicsViewCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = _profile->watch_dynamics.size() - 1 - [index_path item]; // we want to get from end
    anixart::ProfileWatchDynamic::Ptr watch_dynamic = _profile->watch_dynamics[index];
    
    NSDateFormatter* date_formatter = [NSDateFormatter new];
    date_formatter.dateFormat = @"dd.MM";
    
    [cell setCount:watch_dynamic->watched_count totalCount:_max_dynamic_count];
    [cell setTime:[date_formatter stringFromDate:anix_time_point_to_nsdate(watch_dynamic->date)]];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(40, PROFILE_WATCH_DYNAMICS_COLLECTION_VIEW_HEIGHT);
}
@end

@implementation ProfileViewController

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    _profile = profile;
    _profile_id = profile->id;
    
    return self;
}
-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    _profile_id = profile_id;
    
    return self;
}
-(instancetype)initWithMyProfile {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    _profile_id = [_app_data_controller getMyProfileID];
    _is_my_profile = YES;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    
    if (_profile) {
        [self setup];
        [self setupLayout];
    } else {
        [self loadProfile];
    }
}

-(void)preSetup {
    _loading_view = [LoadableView new];
    _loading_view.delegate = self;
    
    [self.view addSubview:_loading_view];
    
    _loading_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loading_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_loading_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_loading_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_loading_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}
-(void)setup {
    __weak auto weak_self = self;
    _named_sections = [NSMutableArray arrayWithCapacity:4];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"app.profile.title", ""), TO_NSSTRING(_profile->username)];
    
    _scroll_view = [UIScrollView new];
    _scroll_view.refreshControl = [UIRefreshControl new];
    [_scroll_view.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 5;
    _content_stack_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 8, 0, 8);
    
    _avatar_image_view = [LoadableImageView new];
    _avatar_image_view.clipsToBounds = YES;
    _avatar_image_view.layer.cornerRadius = 40;
    
    _username_label = [UILabel new];
    _username_label.text = TO_NSSTRING(_profile->username);
    
    _custom_status_label = [UILabel new];
    _custom_status_label.text = TO_NSSTRING(_profile->status);
    _custom_status_label.numberOfLines = 0;
    _custom_status_label.textAlignment = NSTextAlignmentCenter;
    
    NSMutableArray<NSLayoutConstraint*>* optional_constraints = [NSMutableArray arrayWithCapacity:3];
    
    _status_label = [UILabel new];
    if (_profile->is_online) {
        _status_label.text = NSLocalizedString(@"app.profile.status.online.name", "");
    } else {
        _status_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.profile.status.offline.start", ""), [NSDateFormatter localizedStringFromDate:anix_time_point_to_nsdate(_profile->last_activity_time) dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    }
    
    if (!_profile->roles.empty()) {
        // TODO: center roles horizontally
        _roles_view = [[ProfileRolesView alloc] initWithProfile:_profile];
        [optional_constraints addObject:[_roles_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor]];
    }
    
    _stats_view = [[ProfileStatsBlockView alloc] initWithProfile:_profile];
    _stats_view.delegate = self;
    
    if (!_is_my_profile) {
        _actions_view = [[ProfileActionsView alloc] initWithProfile:_profile isMyProfile:_is_my_profile];
        _actions_view.delegate = self;
        [optional_constraints addObject:[_actions_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor]];
    }
    
    _lists_view = [[ProfileListsView alloc] initWithProfile:_profile];
    
    NamedSectionView* lists_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.profile.lists", "") view:_lists_view];
    [lists_section_view setShowAllButtonEnabled:!_is_my_profile];
    [lists_section_view setShowAllHandler:^{
        [weak_self onListsShowAllPressed];
    }];
    [_named_sections addObject:lists_section_view];
    
    if (!_profile->votes.empty()) {
        ReleasesPageableDataProvider* data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_profile->votes];
        _votes_view_controller = [[ReleasesVotesTableViewController alloc] initWithTableView:[DynamicTableView new] releasesPageableDataProvider:data_provider];
        _votes_view_controller.is_container_view_controller = YES;
        [self addChildViewController:_votes_view_controller];
        
        NamedSectionView* votes_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.profile.votes", "") view:_votes_view_controller.view];
        [votes_section_view setShowAllButtonEnabled:YES];
        [votes_section_view setShowAllHandler:^{
            [weak_self onVotesShowAllPressed];
        }];
        [_named_sections addObject:votes_section_view];
    }
    
    _watch_dynamics_view = [[ProfileWatchDynamicsView alloc] initWithProfile:_profile];
    _watch_dynamics_view.layoutMargins = UIEdgeInsetsZero;
    
    NamedSectionView* watch_dynamics_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.profile.watch_dynamics", "") view:_watch_dynamics_view];
    [_named_sections addObject:watch_dynamics_section_view];
    
    if (!_profile->history.empty()) {
        ReleasesPageableDataProvider* data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_profile->history];
        _watched_recently_view_controller = [[ReleasesHistoryTableViewController alloc] initWithTableView:[DynamicTableView new] releasesPageableDataProvider:data_provider];
        _watched_recently_view_controller.is_container_view_controller = YES;
        [self addChildViewController:_watched_recently_view_controller];
        
        NamedSectionView* watched_recently_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.profile.watched_recently", "") view:_watched_recently_view_controller.view];
        [_named_sections addObject:watched_recently_section_view];
    }
    
    [self.view addSubview:_scroll_view];
    [_scroll_view addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_avatar_image_view];
    [_content_stack_view addArrangedSubview:_username_label];
    [_content_stack_view addArrangedSubview:_custom_status_label];
    [_content_stack_view addArrangedSubview:_status_label];
    if (!_profile->roles.empty()) {
        [_content_stack_view addArrangedSubview:_roles_view];
    }
    [_content_stack_view addArrangedSubview:_stats_view];
    [_content_stack_view addArrangedSubview:_actions_view];
    for (NamedSectionView* named_section : _named_sections) {
        [_content_stack_view addArrangedSubview:named_section];
        named_section.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
        
        named_section.translatesAutoresizingMaskIntoConstraints = NO;
        [named_section.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor].active = YES;
    }
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _custom_status_label.translatesAutoresizingMaskIntoConstraints = NO;
    _roles_view.translatesAutoresizingMaskIntoConstraints = NO;
    _status_label.translatesAutoresizingMaskIntoConstraints = NO;
    _stats_view.translatesAutoresizingMaskIntoConstraints = NO;
    _actions_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [_content_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_content_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor],
        
        [_avatar_image_view.heightAnchor constraintEqualToConstant:80],
        [_avatar_image_view.widthAnchor constraintEqualToConstant:80],
        
        [_username_label.widthAnchor constraintLessThanOrEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_custom_status_label.widthAnchor constraintLessThanOrEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_status_label.widthAnchor constraintLessThanOrEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_stats_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
    ]];
    [NSLayoutConstraint activateConstraints:optional_constraints];
    [_username_label sizeToFit];
    [_custom_status_label sizeToFit];
    [_status_label sizeToFit];
    
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(_profile->avatar_url)];
    [_avatar_image_view tryLoadImageWithURL:avatar_url];
}
-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)setupLayout {
    _avatar_image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _username_label.textColor = [AppColorProvider textColor];
    _custom_status_label.textColor = [AppColorProvider textColor];
    _status_label.textColor = [AppColorProvider textSecondaryColor];
}
-(void)refresh {
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(_profile->avatar_url)];
    [_avatar_image_view tryLoadImageWithURL:avatar_url];
    _username_label.text = TO_NSSTRING(_profile->username);
    _custom_status_label.text = TO_NSSTRING(_profile->status);
    if (_profile->is_online) {
        _status_label.text = NSLocalizedString(@"app.profile.status.online.name", "");
    } else {
        _status_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.profile.status.offline.start", ""), [NSDateFormatter localizedStringFromDate:anix_time_point_to_nsdate(_profile->last_activity_time) dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    }
    [_stats_view setProfile:_profile];
    [_actions_view setProfile:_profile];
    [_lists_view setProfile:_profile];
    ReleasesPageableDataProvider* votes_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_profile->votes];
    [_votes_view_controller setReleasesPageableDataProvider:votes_data_provider];
    [_watch_dynamics_view setProfile:_profile];
    ReleasesPageableDataProvider* history_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_profile->history];
    [_watched_recently_view_controller setReleasesPageableDataProvider:history_data_provider];
}
-(void)loadProfile {
    [_loading_view startLoading];
    if (_is_my_profile) {
        [self loadAsyncMyProfile];
        return;
    }
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        auto [profile, is_my_profile] = api->profiles().get_profile(self->_profile_id);
        self->_profile = std::move(profile);
        self->_is_my_profile = is_my_profile;
        return NO;
    } completion:^(BOOL errored) {
        [self->_loading_view endLoadingWithErrored:errored];
        if (!errored) {
            [self setup];
            [self setupLayout];
        }
    }];
}
-(void)loadAsyncMyProfile {
    [[SharedRunningData sharedInstance] asyncGetMyProfile:^(anixart::Profile::Ptr profile) {
        [self->_loading_view endLoadingWithErrored:!profile];
        if (profile) {
            self->_profile = profile;
            [self setup];
            [self setupLayout];
        }
    }];
}

-(void)didCollectionsPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    [self.navigationController pushViewController:[[CollectionsCollectionViewController alloc] initWithPages:_api_proxy.api->collections().profile_collections(_profile->id, 0) axis:UICollectionViewScrollDirectionVertical] animated:YES];
}

-(void)didCommentsPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    CommentsTableViewController* release_comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->profiles().get_profile_release_comments(_profile->id, 0, anixart::Comment::Sort::Newest)];
    release_comments_view_controller.enable_origin_reference = YES;
    release_comments_view_controller.delegate = self;
    
    CommentsTableViewController* collection_comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->profiles().get_profile_collection_comments(_profile->id, 0, anixart::Comment::Sort::Newest)];
    collection_comments_view_controller.enable_origin_reference = YES;
    collection_comments_view_controller.delegate = self;
    
    SegmentedPageViewController* page_view_controller = [SegmentedPageViewController new];
    [self.navigationController pushViewController:page_view_controller animated:NO];
    [page_view_controller setPageViewControllers:@[
        release_comments_view_controller,
        collection_comments_view_controller
    ]];
    [page_view_controller setSegmentTitles:@[
        NSLocalizedString(@"app.profile.comments.release.segment", ""),
        NSLocalizedString(@"app.profile.comments.collection.segment", ""),
    ]];
    

}

-(void)didFriendsPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    [self.navigationController pushViewController:[[ProfileFriendsViewController alloc] initWithProfileID:_profile->id isMyProfile:_is_my_profile] animated:YES];
}

-(void)didVideosPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    // TODO
}

-(void)didAcceptFriendRequestPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->profiles().send_friend_request(self->_profile->id);
        return YES;
    } withUICompletion:^{
        // TODO: verify friend status
        [self->_actions_view setFriendStatus:anixart::Profile::FriendStatus::Friends];
    }];
}

-(void)didAddToFriendsPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->profiles().send_friend_request(self->_profile->id);
        return YES;
    } withUICompletion:^{
        // TODO: verify friend status
        [self->_actions_view setFriendStatus:anixart::Profile::FriendStatus::SendedRequest];
    }];
}

-(void)didCancelFriendRequestPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->profiles().remove_friend_request(self->_profile->id);
        return YES;
    } withUICompletion:^{
        // TODO: verify friend status
        [self->_actions_view setFriendStatus:anixart::Profile::FriendStatus::NotFriends];
    }];
}

-(void)didEditPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {

}

-(void)didMessagePressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    // TODO
}

-(void)didRejectFriendRequestPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    // TODO: check
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->profiles().remove_friend_request(self->_profile->id);
        return YES;
    } withUICompletion:^{
        // TODO: verify friend status
        [self->_actions_view setFriendStatus:anixart::Profile::FriendStatus::NotFriends];
    }];
}

-(void)didRemoveFromFriendsPressedForProfileActionsView:(ProfileActionsView *)profile_actions_view {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->profiles().remove_friend_request(self->_profile->id);
        return YES;
    } withUICompletion:^{
        // TODO: verify friend status
        [self->_actions_view setFriendStatus:anixart::Profile::FriendStatus::RecievedRequest];
    }];
}

-(IBAction)onRefresh:(UIRefreshControl*)refresh_control {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        auto [profile, is_my_profile] = api->profiles().get_profile(self->_profile_id);
        self->_profile = profile;
        return YES;
    } withUICompletion:^{
        [self refresh];
        [refresh_control endRefreshing];
    }];
}

-(void)didReplyPressedForCommentsTableView:(UITableView *)table_view comment:(anixart::Comment::Ptr)comment {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithReplyToComment:comment] animated:YES];
}

-(void)onVotesShowAllPressed {
    // TODO
//    ReleasesPageableDataProvider* data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:_api_proxy.api->releases().profile_voted_releases(_profile->id, Release::ByVoteSort::Descending, 0)];
//    ReleasesVotesViewController
}

-(void)onListsShowAllPressed {
    // TODO
}

-(void)didReloadedForLoadableView:(LoadableView*)loadableView {
    if (!_profile) {
        [self loadProfile];
    } else {
        [self refresh];
    }
}

@end
