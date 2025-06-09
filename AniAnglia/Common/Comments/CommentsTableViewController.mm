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
@property(nonatomic, retain) UIButton* avatar_button;
@property(nonatomic, retain) LoadableImageView* avatar_image_view;
@property(nonatomic, retain) UILabel* username_label;
@property(nonatomic, retain) UILabel* origin_label;
@property(nonatomic, retain) UILabel* publish_date_label;
@property(nonatomic, retain) UILabel* origin_name_label;
@property(nonatomic, retain) UILabel* content_label;
@property(nonatomic, retain) UIButton* reply_button;
@property(nonatomic, retain) UIButton* show_replies_button;
@property(nonatomic, retain) UIButton* upvote_button;
@property(nonatomic, retain) UIButton* downvote_button;
@property(nonatomic, retain) UILabel* vote_count_label;
@property(nonatomic, retain) NSLayoutConstraint* show_replies_button_height_constraint;

@property(nonatomic, retain) UIVisualEffectView* blur_effect_view;
@property(nonatomic, retain) UIButton* spoiler_show_button;

-(void)highlightCell;

@end

@interface CommentsTableViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching, CommentsTableViewCellDelegate> {
    anixart::Pageable<anixart::Comment>::UPtr _pages;
    std::vector<anixart::Comment::Ptr> _comments;
    
    anixart::ProfileID _my_profile_id;
}
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic) AppDataController* app_data_controller;
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
    _avatar_button = [UIButton new];
    [_avatar_button addTarget:self action:@selector(onAvatarPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _avatar_image_view = [LoadableImageView new];
    _avatar_image_view.clipsToBounds = YES;
    _avatar_image_view.layer.cornerRadius = 20;
    
    _username_label = [UILabel new];
    _origin_label = [UILabel new];
    _publish_date_label = [UILabel new];
    _origin_name_label = [UILabel new];
    
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
    
    _blur_effect_view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
    _blur_effect_view.layer.cornerRadius = 8;
    _blur_effect_view.clipsToBounds = YES;
    
    _spoiler_show_button = [UIButton new];
    [_spoiler_show_button setTitle:NSLocalizedString(@"app.comments.spoiler.show", "") forState:UIControlStateNormal];
    [_spoiler_show_button addTarget:self action:@selector(onSpoilerShowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_avatar_button];
    [_avatar_button addSubview:_avatar_image_view];
    [self.contentView addSubview:_username_label];
    [self.contentView addSubview:_origin_label];
    [self.contentView addSubview:_publish_date_label];
    [self.contentView addSubview:_origin_name_label];
    [self.contentView addSubview:_content_label];
    [self.contentView addSubview:_reply_button];
    [self.contentView addSubview:_show_replies_button];
    [self.contentView addSubview:_upvote_button];
    [self.contentView addSubview:_downvote_button];
    [self.contentView addSubview:_vote_count_label];
    
    _avatar_button.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _username_label.translatesAutoresizingMaskIntoConstraints = NO;
    _origin_label.translatesAutoresizingMaskIntoConstraints = NO;
    _publish_date_label.translatesAutoresizingMaskIntoConstraints = NO;
    _origin_name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    _reply_button.translatesAutoresizingMaskIntoConstraints = NO;
    _show_replies_button.translatesAutoresizingMaskIntoConstraints = NO;
    _upvote_button.translatesAutoresizingMaskIntoConstraints = NO;
    _downvote_button.translatesAutoresizingMaskIntoConstraints = NO;
    _vote_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _blur_effect_view.translatesAutoresizingMaskIntoConstraints = NO;
    _spoiler_show_button.translatesAutoresizingMaskIntoConstraints = NO;
    
    _show_replies_button_height_constraint =
    [_show_replies_button.heightAnchor constraintEqualToConstant:0];
    NSArray* constraints = @[
        [_username_label.heightAnchor constraintGreaterThanOrEqualToConstant:10],
        [_content_label.heightAnchor constraintGreaterThanOrEqualToConstant:10],
        [_publish_date_label.heightAnchor constraintGreaterThanOrEqualToConstant:10],
    ];
    for (NSLayoutConstraint* constr : constraints) {
        constr.priority = 700;
    }
    [NSLayoutConstraint activateConstraints:@[
        [_avatar_button.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_avatar_button.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_avatar_button.widthAnchor constraintEqualToConstant:40],
        [_avatar_button.heightAnchor constraintEqualToConstant:40],
        
        [_avatar_image_view.topAnchor constraintEqualToAnchor:_avatar_button.topAnchor],
        [_avatar_image_view.leadingAnchor constraintEqualToAnchor:_avatar_button.leadingAnchor],
        [_avatar_image_view.trailingAnchor constraintEqualToAnchor:_avatar_button.trailingAnchor],
        [_avatar_image_view.bottomAnchor constraintEqualToAnchor:_avatar_button.bottomAnchor],
        
        [_username_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_username_label.leadingAnchor constraintEqualToAnchor:_avatar_image_view.trailingAnchor constant:9],
        
        [_origin_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_origin_label.leadingAnchor constraintEqualToAnchor:_username_label.trailingAnchor constant:4],
        [_origin_label.bottomAnchor constraintEqualToAnchor:_username_label.bottomAnchor],
        
        [_publish_date_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_publish_date_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_origin_label.trailingAnchor constant:4],
        [_publish_date_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_publish_date_label.bottomAnchor constraintEqualToAnchor:_username_label.bottomAnchor],
        
        [_origin_name_label.topAnchor constraintEqualToAnchor:_username_label.bottomAnchor constant:5],
        [_origin_name_label.leadingAnchor constraintEqualToAnchor:_username_label.leadingAnchor],
        [_origin_name_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        
        [_content_label.topAnchor constraintEqualToAnchor:_origin_name_label.bottomAnchor constant:5],
        [_content_label.leadingAnchor constraintEqualToAnchor:_origin_name_label.leadingAnchor],
        [_content_label.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        
        [_reply_button.topAnchor constraintEqualToAnchor:_content_label.bottomAnchor constant:5],
        [_reply_button.leadingAnchor constraintEqualToAnchor:_content_label.leadingAnchor],
        [_reply_button.heightAnchor constraintEqualToConstant:20],
        [_reply_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor],
        
        [_upvote_button.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
//        [_downvote_button.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor],
        [_upvote_button.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_vote_count_label.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
        [_vote_count_label.leadingAnchor constraintEqualToAnchor:_upvote_button.trailingAnchor constant:5],
        [_vote_count_label.widthAnchor constraintGreaterThanOrEqualToConstant:40],
        [_vote_count_label.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_downvote_button.topAnchor constraintEqualToAnchor:_reply_button.topAnchor],
        [_downvote_button.leadingAnchor constraintEqualToAnchor:_vote_count_label.trailingAnchor constant:5],
        [_downvote_button.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_downvote_button.bottomAnchor constraintEqualToAnchor:_reply_button.bottomAnchor],
        
        [_show_replies_button.topAnchor constraintEqualToAnchor:_reply_button.bottomAnchor constant:9],
        [_show_replies_button.leadingAnchor constraintEqualToAnchor:_reply_button.leadingAnchor],
        [_show_replies_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        _show_replies_button_height_constraint,
        [_show_replies_button.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
    ]];
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
        [self.contentView addSubview:_blur_effect_view];
        [self.contentView addSubview:_spoiler_show_button];
        
        [NSLayoutConstraint activateConstraints:@[
            [_blur_effect_view.topAnchor constraintEqualToAnchor:_content_label.topAnchor],
            [_blur_effect_view.leadingAnchor constraintEqualToAnchor:_content_label.leadingAnchor],
            [_blur_effect_view.trailingAnchor constraintEqualToAnchor:_content_label.trailingAnchor],
            [_blur_effect_view.bottomAnchor constraintEqualToAnchor:_content_label.bottomAnchor],
            
            [_spoiler_show_button.topAnchor constraintEqualToAnchor:_content_label.topAnchor],
            [_spoiler_show_button.leadingAnchor constraintEqualToAnchor:_content_label.leadingAnchor],
            [_spoiler_show_button.trailingAnchor constraintEqualToAnchor:_content_label.trailingAnchor],
            [_spoiler_show_button.bottomAnchor constraintEqualToAnchor:_content_label.bottomAnchor],
        ]];
    } else {
        [_blur_effect_view removeFromSuperview];
        [_spoiler_show_button removeFromSuperview];
    }
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
    [_content_label sizeToFit];
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
    _app_data_controller = [AppDataController sharedInstance];
    _my_profile_id = [_app_data_controller getMyProfileID];
    _lock = [NSLock new];
    _table_view = table_view;
    _pages = std::move(pages);
    _enable_origin_reference = NO;
    
    return self;
}

-(instancetype)initWithTableView:(UITableView*)table_view comments:(std::vector<anixart::Comment::Ptr>)comments {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _table_view = table_view;
    _comments = comments;
    _enable_origin_reference = NO;
    _enable_context_menu = NO;
    
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_table_view reloadData];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    _table_view.scrollEnabled = NO;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    if (_pages) {
        [self loadFirstPage];
    }
    else if (!_comments.empty()) {
        [_table_view reloadData];
    }
}

-(void)viewWillLayoutSubviews {
    _table_view.contentOffset = CGPointZero;
//    _table_view.contentInset = UIEdgeInsetsZero;
//    _table_view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

-(void)setup {
    [_table_view registerClass:CommentsTableViewCell.class forCellReuseIdentifier:[CommentsTableViewCell getIdentifier]];
    _table_view.rowHeight = UITableViewAutomaticDimension;
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    
    // TEST
//    self.edgesForExtendedLayout = 0;
    
    _loadable_view = [LoadableView new];
    
    [self.view addSubview:_table_view];
    [self.view addSubview:_loadable_view];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    if (_is_container_view_controller) {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_table_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
            [_table_view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    }
    else {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor]
        ]];
    }
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Comment::Ptr>(^)())block completion:(void(^)())completion {
    if (!_pages) {
        return;
    }
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        /* todo: change to thread-safe */
        [self->_lock lock];
        auto new_items = block();
        self->_comments.insert(self->_comments.end(), new_items.begin(), new_items.end());
        [self->_lock unlock];
        return YES;
    } withUICompletion:^{
        completion();
    }];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Comment::Ptr>(^)())block {
    [self appendItemsFromBlock:block completion:^{
        [self->_loadable_view endLoading];
        [self->_table_view reloadData];
        [self callDelegateDidGotPage];
    }];
}

-(void)loadFirstPage {
    [_loadable_view startLoading];
    [self appendItemsFromBlock:^{
        // TODO: fix another way
        if (self->_pages->get_current_page() != 0 && self->_pages->is_end()) {
            return std::vector<anixart::Comment::Ptr>();
        }
        return self->_pages->get();
    }];
}
-(void)loadNextPage {
    [self appendItemsFromBlock:^{
        if (self->_pages->is_end()) {
            return std::vector<anixart::Comment::Ptr>();
        }
        return self->_pages->next();
    }];
}

-(void)callDelegateDidGotPage {
    if ([_delegate respondsToSelector:@selector(commentsTableView:didGotPageAtIndex:)]) {
        [_delegate commentsTableView:_table_view didGotPageAtIndex:_pages->get_current_page()];
    }
}

-(void)setPages:(anixart::Pageable<anixart::Comment>::UPtr)pages {
    // TODO: fix race condition
    _pages = std::move(pages);
    [self reset];
    [self loadFirstPage];
}
-(void)reset {
    /* todo: load cancel */
    _comments.clear();
    [_table_view reloadData];
}
-(void)refresh {
    // TODO: maybe not reset full comments array, but because this pageable always returns *all* comment, we can ignore it
    _comments.clear();
    [self appendItemsFromBlock:^{
        return self->_pages->go(0);
    } completion:^{
        NSIndexSet* sections = [NSIndexSet indexSetWithIndex:0];
        [self->_table_view reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        [self callDelegateDidGotPage];
    }];
}

-(void)setHeaderView:(UIView*)header_view {
    _table_view.tableHeaderView = header_view;
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
    // TODO: maybe unefficient, due to vector of shared_ptr's. If it's a problem, will need to improve libanixart
    auto iter = std::find_if(_comments.begin(), _comments.end(), [comment_id](anixart::Comment::Ptr& comment) {
        return comment->id == comment_id;
    });
    return iter != _comments.end() ? std::distance(_comments.begin(), iter) : NSNotFound;
}
-(void)scrollToCommentAtIndex:(NSInteger)comment_index {
    if (comment_index >= _comments.size()) {
        return;
    }
    NSIndexPath* index_path = [NSIndexPath indexPathForRow:comment_index inSection:0];
    [_table_view scrollToRowAtIndexPath:index_path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    // TODO: add this to willDisplayCell, because now it's not on the screen and animating wont work
//    CommentsTableViewCell* cell = [_table_view cellForRowAtIndexPath:index_path];
//    [cell highlightCell];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _comments.size();
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    CommentsTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[CommentsTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr& comment = _comments[index];
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(comment->author->avatar_url)];
    
    cell.selectionStyle = _enable_origin_reference ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(comment->author->username)];
    [cell setPublishDate:to_utc_yy_mm_dd_string_from_gmt(comment->date)];
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
    
    return cell;
}

-(UIContextMenuConfiguration *)tableView:(UITableView *)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    if (!_enable_context_menu) {
        return nil;
    }
    NSInteger index = index_path.row;
    anixart::Comment::Ptr& comment = _comments[index];
    
    NSArray* actions;
    if (comment->author->id == _my_profile_id) {
        UIAction* remove_action = [UIAction actionWithTitle:NSLocalizedString(@"app.comments.comment.remove", "") image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(UIAction* action) {
            [self onRemoveContextMenuItemSelectedAtIndex:index];
        }];
        remove_action.attributes = UIMenuOptionsDestructive;
        actions = @[
            [UIAction actionWithTitle:NSLocalizedString(@"app.comments.comment.copy_text", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
                [self onCopyTextContextMenuItemSelectedAtIndex:index];
            }],
            [UIAction actionWithTitle:NSLocalizedString(@"app.comments.comment.edit", "") image:[UIImage systemImageNamed:@"pencil"] identifier:nil handler:^(UIAction* action) {
                [self onEditContextMenuItemSelectedAtIndex:index];
            }],
            remove_action
        ];
    } else {
        UIAction* report_action = [UIAction actionWithTitle:NSLocalizedString(@"app.comments.comment.report", "") image:[UIImage systemImageNamed:@"megaphone"] identifier:nil handler:^(UIAction* action) {
            [self onReportContextMenuItemSelectedAtIndex:index];
        }];
        report_action.attributes = UIMenuOptionsDestructive;
        actions = @[
            [UIAction actionWithTitle:NSLocalizedString(@"app.comments.comment.copy_text", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
                [self onCopyTextContextMenuItemSelectedAtIndex:index];
            }],
            report_action
        ];
    }
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^(NSArray* suggested_actions) {
        return [UIMenu menuWithChildren:actions];
    }];
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if (!_pages || _pages->is_end()) {
        return;
    }
    NSUInteger item_count = [_table_view numberOfRowsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [self loadNextPage];
            return;
        }
    }
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    if (_enable_origin_reference) {
        NSInteger index = index_path.row;
        anixart::Comment::Ptr& comment = _comments[index];
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
    anixart::Comment::Ptr comment = _comments[index];
    
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithComment:comment] animated:YES];
}
-(void)didUpvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = _comments[index];
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
    anixart::Comment::Ptr comment = _comments[index];
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
    anixart::Comment::Ptr comment = _comments[index];
    
    [_delegate didReplyPressedForCommentsTableView:_table_view comment:comment];
}
-(void)didAvatarPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    NSIndexPath* index_path = [_table_view indexPathForCell:comment_table_view_cell];
    NSInteger index = index_path.row;
    anixart::Comment::Ptr comment = _comments[index];
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:comment->author->id] animated:YES];
}

-(void)onCopyTextContextMenuItemSelectedAtIndex:(NSInteger)index {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(_comments[index]->message);
}
-(void)onEditContextMenuItemSelectedAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(commentsTableView:didEditContextMenuSelected:)]) {
        anixart::Comment::Ptr& comment = _comments[index];
        [_delegate commentsTableView:_table_view didEditContextMenuSelected:comment];
    }
}
-(void)onRemoveContextMenuItemSelectedAtIndex:(NSInteger)index {
    anixart::Comment::Ptr& comment = _comments[index];
    BOOL is_release_comment = comment->release ? YES : NO;
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (is_release_comment) {
            api->releases().remove_release_comment(comment->id);
        } else {
            api->collections().remove_comment(comment->id);
        }
        return YES;
    } withUICompletion:^{
        [self refresh];
    }];
}
-(void)onReportContextMenuItemSelectedAtIndex:(NSInteger)index {
    // TODO
}


@end
