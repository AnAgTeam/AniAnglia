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

@class ProfileStatsBlockView;
@class ProfileActionsView;
@class ProfileVotesView;
@class ProfileWatchedRecentlyView;

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

@protocol ProfileVotesViewDelegate <NSObject>
-(void)profileVotesView:(ProfileVotesView*)profile_votes_view didSelectVotedRelease:(anixart::Release::Ptr)release;
@end

@protocol ProfileWatchedRecentlyViewDelegate <NSObject>
-(void)profileWatchedRecentlyView:(ProfileWatchedRecentlyView*)profile_watched_recently_view didSelectRelease:(anixart::Release::Ptr)release;
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

@interface ProfileVotesViewTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) NSArray<UIImageView*>* star_views;
@property(nonatomic, retain) UIStackView* stars_stack_view;
@property(nonatomic, retain) UILabel* vote_time_label;

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setStarsCount:(NSInteger)stars_count;
-(void)setVoteTime:(NSString*)vote_time;
@end

@interface ProfileVotesView : UIView <UITableViewDataSource, UITableViewDelegate> {
    anixart::Profile::Ptr _profile;
}
@property(nonatomic, weak) id<ProfileVotesViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UITableView* votes_table_view;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
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
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UICollectionView* dynamics_collection_view;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
@end

@interface ProfileWatchedRecentlyViewTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* episode_label;
@property(nonatomic, retain) UILabel* time_label;

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setEpisode:(NSString*)episode;
-(void)setTime:(NSString*)time;
@end

@interface ProfileWatchedRecentlyView : UIView <UITableViewDataSource, UITableViewDelegate> {
    anixart::Profile::Ptr _profile;
}
@property(nonatomic, weak) id<ProfileWatchedRecentlyViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UITableView* releases_table_view;

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;

-(void)setProfile:(anixart::Profile::Ptr)profile;
@end

@interface ProfileViewController () <ProfileStatsBlockViewDelegate, ProfileActionViewDelegate, ProfileVotesViewDelegate, ProfileWatchedRecentlyViewDelegate> {
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
@property(nonatomic, retain) UILabel* status_label;
@property(nonatomic, retain) UIButton* action_button;

@property(nonatomic, retain) ProfileStatsBlockView* stats_view;
@property(nonatomic, retain) ProfileActionsView* actions_view;
@property(nonatomic, retain) ProfileListsView* lists_view;
@property(nonatomic, retain) ProfileVotesView* votes_view;
@property(nonatomic, retain) ProfileWatchDynamicsView* watch_dynamics_view;
@property(nonatomic, retain) ProfileWatchedRecentlyView* watched_recently_view;


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

@implementation ProfileVotesViewTableViewCell

+(NSString*)getIdentifier {
    return @"ProfileVotesViewTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    
    _title_label = [UILabel new];
    _stars_stack_view = [UIStackView new];
    _stars_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _stars_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _stars_stack_view.alignment = UIStackViewAlignmentCenter;
    
    _vote_time_label = [UILabel new];
    
    _star_views = @[
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]],
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]],
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]],
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]],
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]]
    ];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_stars_stack_view];
    [self addSubview:_vote_time_label];
    for (UIImageView* star_view : _star_views) {
        [_stars_stack_view addArrangedSubview:star_view];
    }
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _stars_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _vote_time_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(9. / 16)],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:8],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_stars_stack_view.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_stars_stack_view.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_stars_stack_view.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        
        [_vote_time_label.topAnchor constraintEqualToAnchor:_stars_stack_view.topAnchor],
        [_vote_time_label.leadingAnchor constraintEqualToAnchor:_stars_stack_view.trailingAnchor constant:5],
        [_vote_time_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
    ]];
    [_title_label sizeToFit];
    [_vote_time_label sizeToFit];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _vote_time_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setStarsCount:(NSInteger)stars_count {
    for (NSInteger i = 0; i < 5; ++i) {
        _star_views[i].image = [UIImage systemImageNamed:(i < stars_count) ? @"star.fill" : @"star"];
    }
}
-(void)setVoteTime:(NSString*)vote_time {
    _vote_time_label.text = vote_time;
}
@end

@implementation ProfileVotesView

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _profile = profile;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.profile.votes.title", "");
    
    _votes_table_view = [UITableView new];
    [_votes_table_view registerClass:ProfileVotesViewTableViewCell.class forCellReuseIdentifier:[ProfileVotesViewTableViewCell getIdentifier]];
    _votes_table_view.dataSource = self;
    _votes_table_view.delegate = self;
    
    [self addSubview:_me_label];
    [self addSubview:_votes_table_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _votes_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_votes_table_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_votes_table_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_votes_table_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_votes_table_view.heightAnchor constraintEqualToConstant:[self tableView:_votes_table_view numberOfRowsInSection:0] * [self tableView:_votes_table_view heightForRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]]],
        [_votes_table_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

-(void)setProfile:(anixart::Profile::Ptr)profile {
    _profile = profile;
    [_votes_table_view reloadData];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _profile->votes.size();
}
-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return 100;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    ProfileVotesViewTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ProfileVotesViewTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _profile->votes[index];
    
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setStarsCount:release->my_vote];
    [cell setVoteTime:to_utc_yy_mm_dd_string_from_gmt(release->voted_date)];
    
    return cell;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _profile->votes[index];
    
    [_delegate profileVotesView:self didSelectVotedRelease:release];
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
    if (total_count == 0) {
        return;
    }
    if (_indicator_height_constraint) {
        _indicator_height_constraint.active = NO;
    }
    _indicator_height_constraint = [_indicator_view.heightAnchor constraintEqualToAnchor:_indicator_container_view.heightAnchor multiplier:(static_cast<double>(count) / total_count)];
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
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.profile.watch_dynamics.title", "");
    
    UICollectionViewFlowLayout* dynamics_collection_layout = [UICollectionViewFlowLayout new];
    dynamics_collection_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _dynamics_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:dynamics_collection_layout];
    [_dynamics_collection_view registerClass:ProfileWatchDynamicsViewCollectionViewCell.class forCellWithReuseIdentifier:[ProfileWatchDynamicsViewCollectionViewCell getIdentifier]];
    _dynamics_collection_view.dataSource = self;
    _dynamics_collection_view.delegate = self;
    _dynamics_collection_view.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    
    [self addSubview:_me_label];
    [self addSubview:_dynamics_collection_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _dynamics_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],

        [_dynamics_collection_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:8],
        [_dynamics_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_dynamics_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_dynamics_collection_view.heightAnchor constraintEqualToConstant:PROFILE_WATCH_DYNAMICS_COLLECTION_VIEW_HEIGHT],
        [_dynamics_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_me_label sizeToFit];
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
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ProfileWatchDynamicsViewCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ProfileWatchDynamicsViewCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = _profile->watch_dynamics.size() - 1 - [index_path item]; // we want to get from end
    anixart::ProfileWatchDynamic::Ptr watch_dynamic = _profile->watch_dynamics[index];
    
    [cell setCount:watch_dynamic->watched_count totalCount:_max_dynamic_count];
    [cell setTime:to_gmt_mm_dd_string_from_gmt(watch_dynamic->date)];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(40, PROFILE_WATCH_DYNAMICS_COLLECTION_VIEW_HEIGHT);
}
@end

@implementation ProfileWatchedRecentlyViewTableViewCell

+(NSString*)getIdentifier {
    return @"ProfileWatchedRecentlyViewTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    _title_label = [UILabel new];
    _episode_label = [UILabel new];
    _time_label = [UILabel new];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_episode_label];
    [self addSubview:_time_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _episode_label.translatesAutoresizingMaskIntoConstraints = NO;
    _time_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(9. / 16)],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_episode_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_episode_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        
        [_time_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_time_label.leadingAnchor constraintEqualToAnchor:_episode_label.trailingAnchor constant:5],
        [_time_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]
    ]];
}
-(void)setupLayout {
    _title_label.textColor = [AppColorProvider textColor];
    _episode_label.textColor = [AppColorProvider textSecondaryColor];
    _time_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setEpisode:(NSString*)episode {
    _episode_label.text = episode;
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setTime:(NSString*)time {
    _time_label.text = time;
}
@end

@implementation ProfileWatchedRecentlyView

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile {
    self = [super init];
    
    _profile = profile;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.profile.watched_recently.title", "");
    
    _releases_table_view = [UITableView new];
    [_releases_table_view registerClass:ProfileWatchedRecentlyViewTableViewCell.class forCellReuseIdentifier:[ProfileWatchedRecentlyViewTableViewCell getIdentifier]];
    _releases_table_view.dataSource = self;
    _releases_table_view.delegate = self;
    
    [self addSubview:_me_label];
    [self addSubview:_releases_table_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _releases_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_releases_table_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_releases_table_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_releases_table_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_releases_table_view.heightAnchor constraintEqualToConstant:[self tableView:_releases_table_view numberOfRowsInSection:0] * [self tableView:_releases_table_view heightForRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]]],
        [_releases_table_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    [_me_label sizeToFit];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

-(void)setProfile:(anixart::Profile::Ptr)profile {
    _profile = profile;
    [_releases_table_view reloadData];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _profile->history.size();
}
-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    ProfileWatchedRecentlyViewTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ProfileWatchedRecentlyViewTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _profile->history[index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    NSString* time = [NSString stringWithFormat:@"%@ %@", to_gmt_yy_mm_dd_string_from_gmt(release->last_view_date), to_gmt_hh_mm_string_from_gmt(release->last_view_date)];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setEpisode:TO_NSSTRING(release->last_view_episode->name)];
    [cell setTime:time];
    
    return cell;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _profile->history[index];

    [_delegate profileWatchedRecentlyView:self didSelectRelease:release];
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
        if (_is_my_profile) {
            [[SharedRunningData sharedInstance] asyncGetMyProfile:^(anixart::Profile::Ptr profile) {
                self->_profile = profile;
                [self setup];
                [self setupLayout];
            }];
            return;
        }
        [self loadProfile];
    }
}

-(void)preSetup {
    _loading_view = [LoadableView new];
    
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
    
    _status_label = [UILabel new];
    _status_label.text = _profile->is_online ? NSLocalizedString(@"app.profile.status.online.name", "") : NSLocalizedString(@"app.profile.status.offline.name", "");
    
    NSMutableArray<NSLayoutConstraint*>* optional_constraints = [NSMutableArray arrayWithCapacity:2];
    
    _stats_view = [[ProfileStatsBlockView alloc] initWithProfile:_profile];
    _stats_view.delegate = self;
    
    if (!_is_my_profile) {
        _actions_view = [[ProfileActionsView alloc] initWithProfile:_profile isMyProfile:_is_my_profile];
        _actions_view.delegate = self;
        [optional_constraints addObject:[_actions_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor]];
    }
    
    _lists_view = [[ProfileListsView alloc] initWithProfile:_profile name:NSLocalizedString(@"app.profile.lists.title", "")];
    _lists_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _votes_view = [[ProfileVotesView alloc] initWithProfile:_profile];
    _votes_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _votes_view.delegate = self;
    
    _watch_dynamics_view = [[ProfileWatchDynamicsView alloc] initWithProfile:_profile];
    _watch_dynamics_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _watched_recently_view = [[ProfileWatchedRecentlyView alloc] initWithProfile:_profile];
    _watched_recently_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _watched_recently_view.delegate = self;
    
    [self.view addSubview:_scroll_view];
    [_scroll_view addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_avatar_image_view];
    [_content_stack_view addArrangedSubview:_username_label];
    [_content_stack_view addArrangedSubview:_custom_status_label];
    [_content_stack_view addArrangedSubview:_status_label];
    [_content_stack_view addArrangedSubview:_stats_view];
    [_content_stack_view addArrangedSubview:_actions_view];
    [_content_stack_view addArrangedSubview:_lists_view];
    [_content_stack_view addArrangedSubview:_votes_view];
    [_content_stack_view addArrangedSubview:_watch_dynamics_view];
    [_content_stack_view addArrangedSubview:_watched_recently_view];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _status_label.translatesAutoresizingMaskIntoConstraints = NO;
    _stats_view.translatesAutoresizingMaskIntoConstraints = NO;
    _actions_view.translatesAutoresizingMaskIntoConstraints = NO;
    _lists_view.translatesAutoresizingMaskIntoConstraints = NO;
    _votes_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watch_dynamics_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watched_recently_view.translatesAutoresizingMaskIntoConstraints = NO;
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
        [_lists_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_votes_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_watch_dynamics_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_watched_recently_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor]
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
    _username_label.text = TO_NSSTRING(_profile->username);
    _custom_status_label.text = TO_NSSTRING(_profile->status);
    _status_label.text = _profile->is_online ? NSLocalizedString(@"app.profile.status.online.name", "") : NSLocalizedString(@"app.profile.status.offline.name", "");
    [_stats_view setProfile:_profile];
    [_actions_view setProfile:_profile];
    [_lists_view setProfile:_profile];
    [_votes_view setProfile:_profile];
    [_watch_dynamics_view setProfile:_profile];
    [_watched_recently_view setProfile:_profile];
}
-(void)loadProfile {
    [_loading_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        std::pair<anixart::Profile::Ptr, bool> response = api->profiles().get_profile(self->_profile_id);
        self->_profile = response.first;
        self->_is_my_profile = response.second;
        return YES;
    } withUICompletion:^{
        [self->_loading_view endLoading];
        [self setup];
        [self setupLayout];
    }];
}

-(void)didCollectionsPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    // TODO
}

-(void)didCommentsPressedForProfileStatsBlockView:(ProfileStatsBlockView *)profile_stats_block_view {
    // TODO
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

-(void)profileVotesView:(ProfileVotesView *)profile_votes_view didSelectVotedRelease:(anixart::Release::Ptr)release {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}

-(void)profileWatchedRecentlyView:(ProfileWatchedRecentlyView *)profile_watched_recently_view didSelectRelease:(anixart::Release::Ptr)release {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}

-(IBAction)onRefresh:(UIRefreshControl*)refresh_control {
    // since this not in the main thread, we can call network action directly
    auto [profile, is_my_profile] = _api_proxy.api->profiles().get_profile(_profile_id);
    _profile = profile;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refresh];
        [refresh_control endRefreshing];
    });
}

@end
