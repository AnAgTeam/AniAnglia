//
//  CollectionViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#import <Foundation/Foundation.h>
#import "CollectionViewController.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "ReleasesTableViewController.h"
#import "LoadableView.h"
#import "ExpandableLabel.h"
#import "ProfileListsView.h"
#import "TimeCvt.h"
#import "CommentsTableViewController.h"
#import "ReleaseViewController.h"
#import "CommentRepliesViewController.h"
#import "ProfileViewController.h"

@class CollectionTableHeaderView;
@class CollectionTableAuthorView;

@protocol CollectionTableAuthorViewDelegate <NSObject>
-(void)didAuthorAvatarPressedForCollectionTableAuthorView:(CollectionTableAuthorView*)collection_table_author_view;
@end

@protocol CollectionTableHeaderViewDelegate <NSObject>
-(void)didAuthorAvatarPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view;
-(void)didDescriptionExpandPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view;
-(void)didBookmarkPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view;
-(void)didCommentsPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view;
-(void)didRandomPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view;
@end

@interface CollectionTableHeaderListsView : UIView

@end

@interface CollectionTableAuthorView : UIView {
    anixart::Collection::Ptr _collection;
}
@property(nonatomic, weak) id<CollectionTableAuthorViewDelegate> delegate;
@property(nonatomic, retain) UIButton* avatar_button;
@property(nonatomic, retain) LoadableImageView* avatar_view;
@property(nonatomic, retain) UILabel* username_label;

-(instancetype)initWithCollection:(anixart::Collection::Ptr)collection;
@end

@interface CollectionTableHeaderView : UIView <CollectionTableAuthorViewDelegate, ExpandableLabelDelegate> {
    anixart::CollectionGetInfo::Ptr _collection_get_info;
    anixart::Collection::Ptr _collection;
}
@property(nonatomic, weak) id<CollectionTableHeaderViewDelegate> delegate;
@property(nonatomic, retain) UIStackView* content_stack_view;
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* created_date_label;
@property(nonatomic, retain) UILabel* updated_date_label;
@property(nonatomic, retain) UIStackView* actions_stack_view;
@property(nonatomic, retain) UIButton* bookmark_button;
@property(nonatomic, retain) UIButton* comments_button;
@property(nonatomic, retain) CollectionTableAuthorView* author_view;
@property(nonatomic, retain) ExpandableLabel* description_label;
@property(nonatomic, retain) ProfileListsView* lists_view;
@property(nonatomic, retain) UIButton* random_button;

-(instancetype)initWithCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info;

-(void)updateBookmarkButton;
@end

@interface CollectionViewController () <CollectionTableHeaderViewDelegate, CommentsTableViewControllerDelegate> {
    anixart::CollectionID _collection_id;
    anixart::Collection::Ptr _collection;
    anixart::CollectionGetInfo::Ptr _collection_get_info;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) CollectionTableHeaderView* header_view;
@property(nonatomic, retain) ReleasesTableViewController* releases_view_controller;

@end

@implementation CollectionTableAuthorView

-(instancetype)initWithCollection:(anixart::Collection::Ptr)collection {
    self = [super init];
    
    _collection = collection;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _avatar_button = [UIButton new];
    [_avatar_button addTarget:self action:@selector(onAvatarPressed:) forControlEvents:UIControlEventTouchUpInside];
    _avatar_button.clipsToBounds = YES;
    _avatar_button.layer.cornerRadius = 25;
    
    _avatar_view = [LoadableImageView new];
    _avatar_view.contentMode = UIViewContentModeScaleAspectFill;
    
    _username_label = [UILabel new];
    _username_label.text = TO_NSSTRING(_collection->creator->username);
    _username_label.textAlignment = NSTextAlignmentJustified;
    _username_label.numberOfLines = 0;
    
    [self addSubview:_avatar_button];
    [_avatar_button addSubview:_avatar_view];
    [self addSubview:_username_label];
    
    _avatar_button.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_view.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_avatar_button.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_avatar_button.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_avatar_button.heightAnchor constraintEqualToConstant:50],
        [_avatar_button.widthAnchor constraintEqualToAnchor:_avatar_button.heightAnchor],
        [_avatar_button.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_avatar_view.topAnchor constraintEqualToAnchor:_avatar_button.topAnchor],
        [_avatar_view.leadingAnchor constraintEqualToAnchor:_avatar_button.leadingAnchor],
        [_avatar_view.trailingAnchor constraintEqualToAnchor:_avatar_button.trailingAnchor],
        [_avatar_view.bottomAnchor constraintEqualToAnchor:_avatar_button.bottomAnchor],
        
        [_username_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_username_label.leadingAnchor constraintEqualToAnchor:_avatar_button.trailingAnchor constant:8],
        [_username_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_username_label.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_username_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(_collection->creator->avatar_url)];
    [_avatar_view tryLoadImageWithURL:avatar_url];
}
-(void)setupLayout {
    _avatar_view.backgroundColor = [AppColorProvider foregroundColor1];
    _username_label.textColor = [AppColorProvider textColor];
}

-(IBAction)onAvatarPressed:(UIButton*)sender {
    [_delegate didAuthorAvatarPressedForCollectionTableAuthorView:self];
}

@end

@implementation CollectionTableHeaderView

-(instancetype)initWithCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info {
    self = [super init];
    
    _collection_get_info = collection_get_info;
    _collection = collection_get_info->collection;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 8;
    
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    _image_view.contentMode = UIViewContentModeScaleAspectFill;
    
    _title_label = [UILabel new];
    _title_label.font = [UIFont systemFontOfSize:22];
    _title_label.text = TO_NSSTRING(_collection->title);
    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 0;
    
    _created_date_label = [UILabel new];
    _created_date_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.collection.created.start", ""), to_utc_yy_mm_dd_string_from_gmt(_collection->creation_date)];
    
    _updated_date_label = [UILabel new];
    _updated_date_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.collection.updated.start", ""), to_utc_yy_mm_dd_string_from_gmt(_collection->last_update_date)];
    
    _actions_stack_view = [UIStackView new];
    _actions_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _actions_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _actions_stack_view.alignment = UIStackViewAlignmentCenter;
    
    _bookmark_button = [UIButton new];
    [_bookmark_button setTitle:[@(_collection->favorite_count) stringValue] forState:UIControlStateNormal];
    [self updateBookmarkButton];
    [_bookmark_button addTarget:self action:@selector(onBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _bookmark_button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    _comments_button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3); 
    _bookmark_button.layer.cornerRadius = 8;
    
    _comments_button = [UIButton new];
    [_comments_button setTitle:[@(_collection->comment_count) stringValue] forState:UIControlStateNormal];
    [_comments_button setImage:[UIImage systemImageNamed:@"message"] forState:UIControlStateNormal];
    [_comments_button addTarget:self action:@selector(onCommentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _comments_button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    _comments_button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
    _comments_button.layer.cornerRadius = 8;
    
    _author_view = [[CollectionTableAuthorView alloc] initWithCollection:_collection];
    _author_view.delegate = self;
    
    _description_label = [ExpandableLabel new];
    [_description_label setText:TO_NSSTRING(_collection->description)];
    _description_label.delegate = self;
    
    _lists_view = [[ProfileListsView alloc] initWithCollectionGetInfo:_collection_get_info];
    
    _random_button = [UIButton new];
    [_random_button setTitle:NSLocalizedString(@"app.collection.random.title", "") forState:UIControlStateNormal];
    [_random_button setImage:[UIImage systemImageNamed:@"shuffle"] forState:UIControlStateNormal];
    [_random_button addTarget:self action:@selector(onRandomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _random_button.layer.cornerRadius = 8;
    
    [self addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_image_view];
    [_content_stack_view addArrangedSubview:_title_label];
    [_content_stack_view addArrangedSubview:_created_date_label];
    [_content_stack_view addArrangedSubview:_updated_date_label];
    [_content_stack_view addArrangedSubview:_actions_stack_view];
    [_actions_stack_view addArrangedSubview:[UIView new]];
    [_actions_stack_view addArrangedSubview:_bookmark_button];
    [_actions_stack_view addArrangedSubview:[UIView new]];
    [_actions_stack_view addArrangedSubview:_comments_button];
    [_actions_stack_view addArrangedSubview:[UIView new]];
    [_content_stack_view addArrangedSubview:_author_view];
    [_content_stack_view addArrangedSubview:_description_label];
    [_content_stack_view addArrangedSubview:_lists_view];
    [_content_stack_view addArrangedSubview:_random_button];
    
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _created_date_label.translatesAutoresizingMaskIntoConstraints = NO;
    _updated_date_label.translatesAutoresizingMaskIntoConstraints = NO;
    _actions_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _bookmark_button.translatesAutoresizingMaskIntoConstraints = NO;
    _comments_button.translatesAutoresizingMaskIntoConstraints = NO;
    _author_view.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    _lists_view.translatesAutoresizingMaskIntoConstraints = NO;
    _random_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_stack_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_image_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor multiplier:(9. / 16)],
        [_title_label.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_created_date_label.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_updated_date_label.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_actions_stack_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_actions_stack_view.heightAnchor constraintEqualToConstant:40],
        [_bookmark_button.heightAnchor constraintEqualToAnchor:_actions_stack_view.heightAnchor],
        [_bookmark_button.widthAnchor constraintGreaterThanOrEqualToConstant:60],
        [_comments_button.heightAnchor constraintEqualToAnchor:_actions_stack_view.heightAnchor],
        [_comments_button.widthAnchor constraintGreaterThanOrEqualToConstant:60],
        [_author_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_description_label.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_lists_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_random_button.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_random_button.heightAnchor constraintEqualToConstant:50],
    ]];
    
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(_collection->image_url)];
    [_image_view tryLoadImageWithURL:image_url];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _created_date_label.textColor = [AppColorProvider textSecondaryColor];
    _updated_date_label.textColor = [AppColorProvider textSecondaryColor];
    _bookmark_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_bookmark_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _comments_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_comments_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _random_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_random_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
}

-(void)updateBookmarkButton {
    if (_collection->is_favorite) {
        [_bookmark_button setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
    } else {
        [_bookmark_button setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
    }
}

-(IBAction)onBookmarkButtonPressed:(UIButton*)sender {
    [_delegate didBookmarkPressedForCollectionTableHeaderView:self];
}
-(IBAction)onCommentsButtonPressed:(UIButton*)sender {
    [_delegate didCommentsPressedForCollectionTableHeaderView:self];
}
-(IBAction)onRandomButtonPressed:(UIButton*)sender {
    [_delegate didRandomPressedForCollectionTableHeaderView:self];
}

-(void)didAuthorAvatarPressedForCollectionTableAuthorView:(CollectionTableAuthorView*)collection_table_author_view {
    [_delegate didAuthorAvatarPressedForCollectionTableHeaderView:self];
}

-(void)didExpandPressedForExpandableLabel:(ExpandableLabel*)expandable_label {
    [_delegate didDescriptionExpandPressedForCollectionTableHeaderView:self];
}

@end

@implementation CollectionViewController

-(instancetype)initWithCollectionID:(anixart::CollectionID)collection_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _collection_id = collection_id;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    
    [self loadCollection];
}
-(void)preSetup {
    _loadable_view = [LoadableView new];
    
    [self.view addSubview:_loadable_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_loadable_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_loadable_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_loadable_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}
-(void)setup {
    _header_view = [[CollectionTableHeaderView alloc] initWithCollectionGetInfo:_collection_get_info];
    _header_view.delegate = self;
    
    _releases_view_controller = [[ReleasesTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->collections().collection_releases(_collection->id, 0)];
    _releases_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_releases_view_controller];
    [_releases_view_controller setHeaderView:_header_view];
    
    [self.view addSubview:_releases_view_controller.view];
    
    _header_view.translatesAutoresizingMaskIntoConstraints = NO;
    _releases_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_releases_view_controller.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_releases_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_releases_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_releases_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [_header_view.leadingAnchor constraintEqualToAnchor:_releases_view_controller.view.layoutMarginsGuide.leadingAnchor],
        [_header_view.trailingAnchor constraintEqualToAnchor:_releases_view_controller.view.layoutMarginsGuide.trailingAnchor],
    ]];
}
-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)setupLayout {
    
}

-(void)loadCollection {
    [_loadable_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        self->_collection_get_info = api->collections().get_collection(self->_collection_id);
        self->_collection = self->_collection_get_info->collection;
        return YES;
    } withUICompletion:^{
        [self->_loadable_view endLoading];
        [self setup];
        [self setupLayout];
    }];
}

-(void)didBookmarkPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view {
    BOOL to_set_bookmarked = !_collection->is_favorite;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (to_set_bookmarked) {
            api->collections().add_collection_to_favorites(self->_collection->id);
        } else {
            api->collections().remove_collection_from_favorites(self->_collection->id);
        }
        return YES;
    } withUICompletion:^{
        self->_collection->is_favorite = to_set_bookmarked;
        [self->_header_view updateBookmarkButton];
    }];
}
-(void)didCommentsPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view {
    CommentsTableViewController* comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->collections().collection_comments(_collection->id, anixart::Comment::Sort::Newest, 0)];
    comments_view_controller.delegate = self;
    [self.navigationController pushViewController:comments_view_controller animated:YES];
}
-(void)didRandomPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithRandomCollectionRelease:_collection->id] animated:YES];
}

-(void)didReplyPressedForCommentsTableView:(UITableView *)table_view comment:(anixart::Comment::Ptr)comment {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithReplyToComment:comment] animated:YES];
}

-(void)didAuthorAvatarPressedForCollectionTableHeaderView:(CollectionTableHeaderView *)collection_table_header_view {
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:_collection->creator->id] animated:YES];
}

-(void)didDescriptionExpandPressedForCollectionTableHeaderView:(CollectionTableHeaderView*)collection_table_header_view {
    [self.view layoutIfNeeded];
    [_releases_view_controller setHeaderView:_header_view];
}

@end
