//
//  CommentsTableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.04.2025.
//

#import <Foundation/Foundation.h>
#import "CommentsTableViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "ProfileViewController.h"
#import "StringCvt.h"
#import "TimeCvt.h"
#import "ReleaseViewController.h"
#import "CommentRepliesViewController.h"
#import "CollectionViewController.h"
#import "AppDataController.h"

@interface CommentsTableViewCell ()
@property(nonatomic, retain) UIView* content_view;
@property(nonatomic, retain) UIButton* avatar_button;
@property(nonatomic, retain) LoadableImageView* avatar_image_view;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* origin_label;
@property(nonatomic, retain) UILabel* publish_date_label;
@property(nonatomic, retain) UILabel* origin_name_label;
@property(nonatomic, retain) UILabel* content_label;
@property(nonatomic, retain) UIView* content_container_view;
@property(nonatomic, retain) UIButton* reply_button;
@property(nonatomic, retain) UIButton* show_replies_button;
@property(nonatomic, retain) UIButton* upvote_button;
@property(nonatomic, retain) UIButton* downvote_button;
@property(nonatomic, retain) UILabel* vote_count_label;
@property(nonatomic, retain) NSLayoutConstraint* show_replies_button_height_constraint;
@property(nonatomic) UIEdgeInsets normal_edge_insets;

@property(nonatomic, retain) UIVisualEffectView* blur_effect_view;
@property(nonatomic, retain) UIButton* spoiler_show_button;

-(void)highlightCell;

@end

@interface CommentsTableViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching, CommentsTableViewCellDelegate, LoadableViewDelegate>
@property(nonatomic) BOOL is_first_loading;
@property(nonatomic) UIEdgeInsets content_insets;
@property(nonatomic, retain) CommentsPageableDataProvider* data_provider;
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) NSLock* lock;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;

-(void)setHeaderView:(UIView*)header_view;
@end

@implementation CommentsTableViewCell

+(NSString*)getIdentifier {
    return @"CommentsTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _content_view = [UIView new];
    _content_view.layoutMargins = _normal_edge_insets = UIEdgeInsetsMake(8, 10, 8, 12);
    
    _avatar_button = [UIButton new];
    [_avatar_button addTarget:self action:@selector(onAvatarPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _avatar_image_view = [LoadableImageView new];
    _avatar_image_view.clipsToBounds = YES;
    _avatar_image_view.layer.cornerRadius = 20;
    
    _username_label = [UILabel new];
    _origin_label = [UILabel new];
    _publish_date_label = [UILabel new];
    _origin_name_label = [UILabel new];
    
    _content_container_view = [UIView new];
    _content_container_view.layoutMargins = UIEdgeInsetsMake(4, 0, 4, 0);
    _content_container_view.clipsToBounds = YES;
    
    _content_label = [UILabel new];
    _content_label.numberOfLines = 0;
    _content_label.textAlignment = NSTextAlignmentJustified;
    
    _reply_button = [UIButton new];
    [_reply_button setTitle:NSLocalizedString(@"app.comments.reply_button.title", "") forState:UIControlStateNormal];
    [_reply_button addTarget:self action:@selector(onReplyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _show_replies_button = [UIButton new];
    [_show_replies_button setTitle:NSLocalizedString(@"app.comments.show_replies_button.title", "") forState:UIControlStateNormal];
    [_show_replies_button setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
    [_show_replies_button addTarget:self action:@selector(onShowRepliesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _show_replies_button.clipsToBounds = YES;
    
    _upvote_button = [UIButton new];
    [_upvote_button setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
    [_upvote_button addTarget:self action:@selector(onUpvoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _downvote_button = [UIButton new];
    [_downvote_button setImage:[UIImage systemImageNamed:@"hand.thumbsdown"] forState:UIControlStateNormal];
    [_downvote_button addTarget:self action:@selector(onDownvoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _vote_count_label = [UILabel new];
    
    _blur_effect_view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _blur_effect_view.layer.cornerRadius = 8;
    _blur_effect_view.clipsToBounds = YES;
    
    _spoiler_show_button = [UIButton new];
    [_spoiler_show_button setTitle:NSLocalizedString(@"app.comments.spoiler.show", "") forState:UIControlStateNormal];
    [_spoiler_show_button addTarget:self action:@selector(onSpoilerShowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_content_view];
    [_content_view addSubview:_avatar_button];
    [_avatar_button addSubview:_avatar_image_view];
    [_content_view addSubview:_username_label];
    [_content_view addSubview:_origin_label];
    [_content_view addSubview:_publish_date_label];
    [_content_view addSubview:_origin_name_label];
    [_content_view addSubview:_content_container_view];
    [_content_container_view addSubview:_content_label];
    [_content_view addSubview:_reply_button];
    [_content_view addSubview:_show_replies_button];
    [_content_view addSubview:_upvote_button];
    [_content_view addSubview:_downvote_button];
    [_content_view addSubview:_vote_count_label];
    
    _content_view.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_button.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _origin_label.translatesAutoresizingMaskIntoConstraints = NO;
    _publish_date_label.translatesAutoresizingMaskIntoConstraints = NO;
    _origin_name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _content_container_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    _reply_button.translatesAutoresizingMaskIntoConstraints = NO;
    _show_replies_button.translatesAutoresizingMaskIntoConstraints = NO;
    _upvote_button.translatesAutoresizingMaskIntoConstraints = NO;
    _downvote_button.translatesAutoresizingMaskIntoConstraints = NO;
    _vote_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _blur_effect_view.translatesAutoresizingMaskIntoConstraints = NO;
    _spoiler_show_button.translatesAutoresizingMaskIntoConstraints = NO;
    
    _show_replies_button_height_constraint =
    [_show_replies_button.heightAnchor constraintLessThanOrEqualToConstant:0];
    NSArray* constraints = @[
        [_content_view.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor],
        [_content_view.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_content_view.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_content_view.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
        [_content_view.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor],
        [_content_view.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
    ];
    for (NSLayoutConstraint* constr : constraints) {
        constr.priority = 999;
    }
    [NSLayoutConstraint activateConstraints:@[
        [_avatar_button.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_avatar_button.leadingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.leadingAnchor],
        [_avatar_button.widthAnchor constraintEqualToConstant:40],
        [_avatar_button.heightAnchor constraintEqualToAnchor:_avatar_button.widthAnchor],
        [_avatar_button.bottomAnchor constraintLessThanOrEqualToAnchor:_content_view.layoutMarginsGuide.bottomAnchor],
        
        [_avatar_image_view.topAnchor constraintEqualToAnchor:_avatar_button.topAnchor],
        [_avatar_image_view.leadingAnchor constraintEqualToAnchor:_avatar_button.leadingAnchor],
        [_avatar_image_view.trailingAnchor constraintEqualToAnchor:_avatar_button.trailingAnchor],
        [_avatar_image_view.bottomAnchor constraintEqualToAnchor:_avatar_button.bottomAnchor],
        
        [_username_label.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_username_label.leadingAnchor constraintEqualToAnchor:_avatar_image_view.trailingAnchor constant:9],
        
        [_origin_label.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_origin_label.leadingAnchor constraintEqualToAnchor:_username_label.trailingAnchor constant:4],
        [_origin_label.bottomAnchor constraintEqualToAnchor:_username_label.bottomAnchor],
        
        [_publish_date_label.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_publish_date_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_origin_label.trailingAnchor constant:4],
        [_publish_date_label.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        [_publish_date_label.bottomAnchor constraintEqualToAnchor:_username_label.bottomAnchor],
        
        [_origin_name_label.topAnchor constraintEqualToAnchor:_username_label.bottomAnchor constant:5],
        [_origin_name_label.leadingAnchor constraintEqualToAnchor:_username_label.leadingAnchor],
        [_origin_name_label.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        
        [_content_container_view.topAnchor constraintEqualToAnchor:_origin_name_label.bottomAnchor constant:5],
        [_content_container_view.leadingAnchor constraintEqualToAnchor:_origin_name_label.leadingAnchor],
        [_content_container_view.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        
        [_content_label.topAnchor constraintEqualToAnchor:_content_container_view.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintEqualToAnchor:_content_container_view.layoutMarginsGuide.leadingAnchor],
        [_content_label.trailingAnchor constraintEqualToAnchor:_content_container_view.layoutMarginsGuide.trailingAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:_content_container_view.layoutMarginsGuide.bottomAnchor],
        
        [_reply_button.topAnchor constraintEqualToAnchor:_content_container_view.bottomAnchor constant:5],
        [_reply_button.leadingAnchor constraintEqualToAnchor:_content_container_view.leadingAnchor],
        [_reply_button.heightAnchor constraintLessThanOrEqualToConstant:20],
        [_reply_button.trailingAnchor constraintLessThanOrEqualToAnchor:_content_view.layoutMarginsGuide.centerXAnchor],
        
        [_upvote_button.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
//        [_downvote_button.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor],
        [_upvote_button.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_vote_count_label.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
        [_vote_count_label.leadingAnchor constraintEqualToAnchor:_upvote_button.trailingAnchor constant:5],
        [_vote_count_label.widthAnchor constraintGreaterThanOrEqualToConstant:40],
        [_vote_count_label.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_downvote_button.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
        [_downvote_button.leadingAnchor constraintEqualToAnchor:_vote_count_label.trailingAnchor constant:5],
        [_downvote_button.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        [_downvote_button.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_show_replies_button.topAnchor constraintEqualToAnchor:_reply_button.bottomAnchor constant:9],
        [_show_replies_button.leadingAnchor constraintEqualToAnchor:_reply_button.leadingAnchor],
        [_show_replies_button.trailingAnchor constraintLessThanOrEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        _show_replies_button_height_constraint,
        [_show_replies_button.bottomAnchor constraintLessThanOrEqualToAnchor:_content_view.layoutMarginsGuide.bottomAnchor],
    ]];
    [NSLayoutConstraint activateConstraints:constraints];
}
-(void)setupLayout {
    _avatar_image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _username_label.textColor = [AppColorProvider textSecondaryColor];
    _origin_label.textColor = [AppColorProvider textShyColor];
    _publish_date_label.textColor = [AppColorProvider textShyColor];
    _origin_name_label.textColor = [AppColorProvider textShyColor];
    [_reply_button setTitleColor:[AppColorProvider textSecondaryColor] forState:UIControlStateNormal];
    [_show_replies_button setTitleColor:[AppColorProvider textSecondaryColor] forState:UIControlStateNormal];
    _show_replies_button.tintColor = [AppColorProvider textSecondaryColor];
    _upvote_button.tintColor = [AppColorProvider primaryColor];
    _vote_count_label.textColor = [AppColorProvider textSecondaryColor];
    _downvote_button.tintColor = [AppColorProvider primaryColor];
    [_spoiler_show_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
}

-(void)setBlurred:(BOOL)blurred {
    if (blurred) {
        [_content_container_view addSubview:_blur_effect_view];
        [_content_container_view addSubview:_spoiler_show_button];
        
        [NSLayoutConstraint activateConstraints:@[
            [_blur_effect_view.topAnchor constraintEqualToAnchor:_content_container_view.topAnchor],
            [_blur_effect_view.leadingAnchor constraintEqualToAnchor:_content_container_view.leadingAnchor],
            [_blur_effect_view.trailingAnchor constraintEqualToAnchor:_content_container_view.trailingAnchor],
            [_blur_effect_view.bottomAnchor constraintEqualToAnchor:_content_container_view.bottomAnchor],
            
            [_spoiler_show_button.topAnchor constraintEqualToAnchor:_content_container_view.topAnchor],
            [_spoiler_show_button.leadingAnchor constraintEqualToAnchor:_content_container_view.leadingAnchor],
            [_spoiler_show_button.trailingAnchor constraintEqualToAnchor:_content_container_view.trailingAnchor],
            [_spoiler_show_button.bottomAnchor constraintEqualToAnchor:_content_container_view.bottomAnchor],
        ]];
    } else {
        [_blur_effect_view removeFromSuperview];
        [_spoiler_show_button removeFromSuperview];
    }
}

-(void)setAdditionalContentInsets:(UIEdgeInsets)insets {
    _content_view.layoutMargins = UIEdgeInsetsMake(_normal_edge_insets.top + insets.top, _normal_edge_insets.left + insets.left, _normal_edge_insets.bottom + insets.bottom, _normal_edge_insets.right + insets.right);
}
-(void)setContentInsets:(UIEdgeInsets)insets {
    _content_view.layoutMargins = _normal_edge_insets = insets;
}

-(void)setAvatarUrl:(NSURL*)url {
    [_avatar_image_view tryLoadImageWithURL:url];
}
-(void)setUsername:(NSString*)username {
    _username_label.text = username;
    [_username_label sizeToFit];
}
-(void)setPublishDate:(NSString*)publish_date {
    _publish_date_label.text = publish_date;
    [_publish_date_label sizeToFit];
}
-(void)setContent:(NSString*)content {
    _content_label.text = content;
//    [_content_label sizeToFit];
}
-(void)setVoteCount:(NSInteger)vote_count {
    _vote_count_label.text = [@(vote_count) stringValue];
    [_vote_count_label sizeToFit];
}

-(void)setOrigin:(NSString*)origin name:(NSString*)name {
    _origin_label.text = origin;
    _origin_name_label.text = name;
    [_origin_label sizeToFit];
    [_origin_name_label sizeToFit];
}
-(void)setRepliesCount:(NSInteger)replies_count {
    // enable "show_replies" button if has replies
    _show_replies_button_height_constraint.constant = replies_count != 0 ? 35 : 0;
    // TODO: add replies count to button
}
-(void)setIsSpoiler:(BOOL)spoiler {
    [self setBlurred:spoiler];
}

-(void)highlightCell {
    [self setHighlighted:YES animated:YES];
//    [UIView animateWithDuration:4 delay:2 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^{
//        self.backgroundColor = [AppColorProvider foregroundColor1];
//    } completion:nil];
}

-(IBAction)onAvatarPressed:(UIButton*)sender {
    [_delegate didAvatarPressedCommentForTableViewCell:self];
}
-(IBAction)onReplyButtonPressed:(UIButton*)sender {
    [_delegate didReplyPressedCommentForTableViewCell:self];
}
-(IBAction)onShowRepliesButtonPressed:(UIButton*)sender {
    [_delegate didShowRepliesPressedForCommentTableViewCell:self];
}
-(IBAction)onUpvoteButtonPressed:(UIButton*)sender {
    [_delegate didUpvotePressedForCommentTableViewCell:self];
}
-(IBAction)onDownvoteButtonPressed:(UIButton*)sender {
    [_delegate didDownvotePressedForCommentTableViewCell:self];
}

-(IBAction)onSpoilerShowButtonPressed:(UIButton*)sender {
    [self setBlurred:NO];
}


@end

@implementation CommentsTableViewController

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Comment>::UPtr)pages {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _table_view = table_view;
    _data_provider = [[CommentsPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    _enable_origin_reference = NO;
    _is_first_loading = YES;
    _content_insets = UIEdgeInsetsZero;
    
    __weak auto weak_self = self;
    
    [_data_provider setEditHandler:^(anixart::Comment::Ptr comment) {
        [weak_self onEditSelectedForComment:comment];
    }];
    [_data_provider setReportHandler:^(anixart::Comment::Ptr comment) {
        [weak_self onReportSelectedForComment:comment];
    }];
    [_data_provider loadCurrentPage];
    
    return self;
}

-(instancetype)initWithTableView:(UITableView*)table_view dataProvider:(CommentsPageableDataProvider*)data_provider {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _table_view = table_view;
    _data_provider = data_provider;
    _enable_origin_reference = NO;
    _is_first_loading = NO;
    _content_insets = UIEdgeInsetsZero;
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    if (!_table_view) {
        _table_view = [UITableView new];
    }
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    _table_view.contentInsetAdjustmentBehavior = _is_container_view_controller ? UIScrollViewContentInsetAdjustmentNever : UIScrollViewContentInsetAdjustmentAutomatic;
//    _table_view.alwaysBounceVertical = NO;
    self.view = _table_view;
    self.tableView = _table_view;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    [_table_view reloadData];
}

-(void)setup {
    [_table_view registerClass:CommentsTableViewCell.class forCellReuseIdentifier:[CommentsTableViewCell getIdentifier]];
    _table_view.rowHeight = UITableViewAutomaticDimension;
    
    _loadable_view = [LoadableView new];
    _loadable_view.delegate = self;
    
    [self.view addSubview:_loadable_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor]
    ]];
    if (_is_first_loading) {
        [_loadable_view startLoading];
    }
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return UITableViewAutomaticDimension;
}

-(void)setPages:(anixart::Pageable<anixart::Comment>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}
-(void)clear {
    [_data_provider clear];
}
-(void)reset {
    [_data_provider reset];
}

-(void)setHeaderView:(UIView*)header_view {
    _table_view.tableHeaderView = header_view;
}
-(void)setContentInsets:(UIEdgeInsets)insets {
    _content_insets = insets;
}
-(CGPoint)getContentOffset {
    return _table_view.contentOffset;
}
-(void)setContentOffset:(CGPoint)point {
    [_table_view setContentOffset:point animated:YES];
}
-(void)setKeyboardDismissMode:(UIScrollViewKeyboardDismissMode)dismiss_mode {
    _table_view.keyboardDismissMode = dismiss_mode;
}

-(NSInteger)getCommentIndex:(anixart::CommentID)comment_id {
    return [_data_provider getCommentIndex:comment_id];
}
-(void)scrollToCommentAtIndex:(NSInteger)comment_index {
    if (comment_index >= [_data_provider getItemsCount]) {
        return;
    }
    NSIndexPath* index_path = [NSIndexPath indexPathForRow:comment_index inSection:0];
    [_table_view scrollToRowAtIndexPath:index_path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    // TODO: add this to willDisplayCell, because now it's not on the screen and animating wont work
//    CommentsTableViewCell* cell = [_table_view cellForRowAtIndexPath:index_path];
//    [cell highlightCell];
}

-(void)callDelegateDidGotPageAtIndex:(NSInteger)page_index {
    if ([_delegate respondsToSelector:@selector(commentsTableView:didGotPageAtIndex:)]) {
        [_delegate commentsTableView:_table_view didGotPageAtIndex:page_index];
    }
}
-(void)callDelegateDidFailedPageAtIndex:(NSInteger)page_index {
    if ([_delegate respondsToSelector:@selector(commentsTableView:didFailedPageAtIndex:)]) {
        [_delegate commentsTableView:_table_view didFailedPageAtIndex:page_index];
    }
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_provider getItemsCount];
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    CommentsTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[CommentsTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(comment->author->avatar_url)];
    
    cell.selectionStyle = _enable_origin_reference ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(comment->author->username)];
    [cell setPublishDate:[NSDateFormatter localizedStringFromDate:anix_time_point_to_nsdate(comment->date) dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    [cell setContent:TO_NSSTRING(comment->message)];
    [cell setRepliesCount:comment->reply_count];
    [cell setVoteCount:comment->vote_count];
    [cell setIsSpoiler:comment->is_spoiler];
    if (_enable_origin_reference) {
        if (comment->collection) {
            [cell setOrigin:NSLocalizedString(@"app.comments.origin.collection", "") name:TO_NSSTRING(comment->collection->title)];
        }
        else if (comment->release) {
            [cell setOrigin:NSLocalizedString(@"app.comments.origin.release", "") name:TO_NSSTRING(comment->release->title_ru)];
        }
        else {
            [cell setOrigin:nil name:nil];
        }
    }
    [cell setAdditionalContentInsets:_content_insets];
    
    return cell;
}

-(UIContextMenuConfiguration *)tableView:(UITableView *)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    NSInteger index = index_path.row;
    return [_data_provider getContextMenuConfigurationForItemAtIndex:index];
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if (!_data_provider || [_data_provider isEnd]) {
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
    
    if (_enable_origin_reference) {
        NSInteger index = index_path.row;
        anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
        if (comment->collection) {
            [self.navigationController pushViewController:[[CollectionViewController alloc] initWithCollectionID:comment->collection->id] animated:YES];
        }
        else if (comment->release) {
            [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:comment->release->id] animated:YES];
        }
    }
}

-(void)didShowRepliesPressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithComment:comment] animated:YES];
}
-(void)didUpvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    BOOL is_release_comment = comment->release ? YES : NO;
    
    // TODO: add UI response
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (is_release_comment) {
            api->releases().vote_release_comment(comment->id, anixart::Comment::Sign::Positive);
        } else {
            api->collections().vote_collection_comment(comment->id, anixart::Comment::Sign::Positive);
        }
        return YES;
    } withUICompletion:^{
        
    }];
}
-(void)didDownvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    BOOL is_release_comment = comment->release ? YES : NO;
    
    // TODO: add UI response
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (is_release_comment) {
            api->releases().vote_release_comment(comment->id, anixart::Comment::Sign::Negative);
        } else {
            api->collections().vote_collection_comment(comment->id, anixart::Comment::Sign::Negative);
        }
        return YES;
    } withUICompletion:^{
        
    }];
}
-(void)didReplyPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    
    [_delegate didReplyPressedForCommentsTableView:_table_view comment:comment];
}
-(void)didAvatarPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = [_data_provider getCommentAtIndex:index];
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:comment->author->id] animated:YES];
}

-(void)onEditSelectedForComment:(anixart::Comment::Ptr)comment {
    if ([_delegate respondsToSelector:@selector(commentsTableView:didEditContextMenuSelected:)]) {
        [_delegate commentsTableView:_table_view didEditContextMenuSelected:comment];
    }
}

-(void)onReportSelectedForComment:(anixart::Comment::Ptr)comment {
    // TODO
}

-(void)didUpdatedDataForPageableDataProvider:(PageableDataProvider*)pageable_data_provider {
    [_table_view reloadData];
}

-(void)didReloadedForLoadableView:(LoadableView*)loadable_view {
    [_loadable_view startLoading];
    [_data_provider loadCurrentPage];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadedPageAtIndex:(NSInteger)page_index {
    if (_is_first_loading) {
        _is_first_loading = NO;
        [_loadable_view endLoading];
    }
    [_table_view reloadData];
    [self callDelegateDidGotPageAtIndex:page_index];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didFailedPageAtIndex:(NSInteger)page_index {
    if (_is_first_loading) {
        [_loadable_view endLoadingWithErrored:YES];
    } else {
        [_table_view reloadData];
    }
    [self callDelegateDidFailedPageAtIndex:page_index];
}

@end
