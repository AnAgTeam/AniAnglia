//
//  CommentsReplyTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 14.04.2025.
//

#import <Foundation/Foundation.h>
#import "CommentRepliesViewController.h"
#import "CommentsTableViewController.h"
#import "TextEnterView.h"
#import "StringCvt.h"
#import "AppColor.h"
#import "TimeCvt.h"
#import "ProfileViewController.h"

@interface CommentRepliesViewController () <CommentsTableViewCellDelegate, TextEnterViewDelegate, UIScrollViewDelegate, CommentsTableViewControllerDelegate> {
    anixart::CommentID _comment_id;
    anixart::Comment::Ptr _comment;
    anixart::ProfileID _reply_to_profile_id;
    anixart::Comment::Ptr _reply_to_comment;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) CommentsTableViewCell* replied_comment_view;
@property(nonatomic, retain) CommentsTableViewController* comments_table_view_controller;
@property(nonatomic, retain) TextEnterView* text_enter_view;
@property(nonatomic, retain) NSLayoutConstraint* text_enter_view_bottom_constraint;
@property(nonatomic) CGFloat last_text_enter_origin_y;

@end

@implementation CommentRepliesViewController
-(instancetype)initWithComment:(anixart::Comment::Ptr)comment {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _comment_id = comment->id;
    _comment = comment;
    _reply_to_profile_id = _comment->author->id;
    _last_text_enter_origin_y = -1;
    _reply_to_comment = nullptr;
    
    return self;
}
-(instancetype)initWithReplyToComment:(anixart::Comment::Ptr)comment {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    // TODO: change to some constant
    if (comment->parent_comment_id != anixart::CommentID(0)) {
        _comment_id = comment->parent_comment_id;
        _reply_to_profile_id = comment->author->id;
    } else {
        _comment_id = comment->id;
        _comment = comment;
        _reply_to_profile_id = _comment->author->id;
    }
    _last_text_enter_origin_y = -1;
    _reply_to_comment = comment;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    [self loadParentComment];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_last_text_enter_origin_y >= 0) {
        // this needed to update content offset Y if TextEnterView go up or down, because of keyboard
        CGPoint content_offset = [_comments_table_view_controller getContentOffset];
        content_offset.y = MAX(content_offset.y - _text_enter_view.frame.origin.y - _last_text_enter_origin_y, 0);
        [_comments_table_view_controller setContentOffset:content_offset];
    }
    _last_text_enter_origin_y = _text_enter_view.frame.origin.y;
}

-(void)setup {
    _replied_comment_view = [[CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[CommentsTableViewCell getIdentifier]];
    _replied_comment_view.selectionStyle = UITableViewCellSelectionStyleNone;
    _replied_comment_view.delegate = self;
    
    _comments_table_view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->releases().replies_to_comment(_comment_id, 0, anixart::Comment::Sort::Oldest)];
    [_comments_table_view_controller setHeaderView:_replied_comment_view];
    [self addChildViewController:_comments_table_view_controller];
    [_comments_table_view_controller setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    _comments_table_view_controller.delegate = self;
    
    _text_enter_view = [TextEnterView new];
    _text_enter_view.delegate = self;
    _text_enter_view.placeholder = NSLocalizedString(@"app.comments.text_enter.placeholder", "");
    
    [self.view addSubview:_comments_table_view_controller.view];
    [self.view addSubview:_text_enter_view];
    
    _replied_comment_view.translatesAutoresizingMaskIntoConstraints = NO;
    _replied_comment_view.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _comments_table_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    _text_enter_view.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 15.0, *)) {
        _text_enter_view_bottom_constraint = [_text_enter_view.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor];
    } else {
        _text_enter_view_bottom_constraint = [_text_enter_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
        // Support iOS 14. Very often not working
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    [NSLayoutConstraint activateConstraints:@[
//        [_replied_comment_view.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor],
        [_replied_comment_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_replied_comment_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        
        [_replied_comment_view.contentView.topAnchor constraintEqualToAnchor:_replied_comment_view.topAnchor],
        [_replied_comment_view.contentView.leadingAnchor constraintEqualToAnchor:_replied_comment_view.leadingAnchor],
        [_replied_comment_view.contentView.trailingAnchor constraintEqualToAnchor:_replied_comment_view.trailingAnchor],
        [_replied_comment_view.contentView.bottomAnchor constraintEqualToAnchor:_replied_comment_view.bottomAnchor],
        
        [_comments_table_view_controller.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_comments_table_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:15],
        [_comments_table_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        
        [_text_enter_view.topAnchor constraintEqualToAnchor:_comments_table_view_controller.view.bottomAnchor],
        [_text_enter_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_text_enter_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        _text_enter_view_bottom_constraint
    ]];
    
    [_replied_comment_view layoutIfNeeded];
    [_comments_table_view_controller setHeaderView:_replied_comment_view];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)initParentComment {
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(_comment->author->avatar_url)];
    [_replied_comment_view setAvatarUrl:avatar_url];
    [_replied_comment_view setUsername:TO_NSSTRING(_comment->author->username)];
    [_replied_comment_view setPublishDate:to_utc_yy_mm_dd_string_from_gmt(_comment->date)];
    [_replied_comment_view setContent:TO_NSSTRING(_comment->message)];
    [_replied_comment_view setRepliesCount:0];
    [_replied_comment_view setVoteCount:_comment->vote_count];
    
    [_replied_comment_view layoutIfNeeded];
    [_comments_table_view_controller setHeaderView:_replied_comment_view];
}
-(void)loadParentComment {
    if (_comment) {
        // already loaded
        [self initParentComment];
        if (_reply_to_comment) {
            [self replyToComment:_reply_to_comment];
        }
    } else {
        [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
            self->_comment = api->releases().release_comment(self->_comment_id);
            return YES;
        } withUICompletion:^{
            [self initParentComment];
            if (self->_reply_to_comment) {
                [self replyToComment:self->_reply_to_comment];
            }
        }];
    }
}

-(void)refresh {
    if (_comment->release) {
        [_comments_table_view_controller setPages: self->_api_proxy.api->releases().replies_to_comment(_comment->id, 0, anixart::Comment::Sort::Oldest)];
    }
    else if (_comment->collection) {
        // TODO: recheck api
        [_comments_table_view_controller setPages: self->_api_proxy.api->collections().collection_comment_replies(_comment->id, anixart::Comment::Sign::Negative, 0)];
    }
}
-(void)replyToComment:(anixart::Comment::Ptr)comment {
    NSString* reply_text = [NSString stringWithFormat:@"%@, ", TO_NSSTRING(comment->author->username)];
    [_text_enter_view setText:reply_text];
    [_text_enter_view startEditing];
    _reply_to_profile_id = comment->author->id;
}

-(void)didShowRepliesPressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithComment:_comment] animated:YES];
}
-(void)didUpvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    // TODO: add UI response. Edit API
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().vote_release_comment(self->_comment->id, anixart::Comment::Sign::Positive);
        return YES;
    } withUICompletion:^{
        
    }];
}
-(void)didDownvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    // TODO: add UI response. Edit API
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().vote_release_comment(self->_comment->id, anixart::Comment::Sign::Negative);
        return YES;
    } withUICompletion:^{
        
    }];
}
-(void)didReplyPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    [self replyToComment:_comment];
}
-(void)didAvatarPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell {
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:_comment->author->id] animated:YES];
}

-(void)didSendPressedForTextEnterView:(TextEnterView*)text_enter_view {
    NSString* message = [_text_enter_view getText];
    BOOL is_spoiler = _text_enter_view.is_spoiler;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        anixart::requests::CommentAddRequest request;
        request.message = TO_STDSTRING(message);
        request.parent_comment_id = self->_comment->id;
        request.reply_to_profile_id = self->_reply_to_profile_id;
        request.is_spoiler = is_spoiler;
        
        if (self->_comment->release) {
            api->releases().add_release_comment(self->_comment->release->id, request);
        }
        else if (self->_comment->collection) {
            api->collections().add_collection_comment(self->_comment->collection->id, request);
        }
        return YES;
    } withUICompletion:^{
        [self refresh];
        [self->_text_enter_view setText:@""];
    }];
}
-(void)didReplyPressedForCommentsTableView:(UITableView*)table_view comment:(anixart::Comment::Ptr)comment {
    [self replyToComment:comment];
}

-(void)onKeyboardShow:(NSNotification*)notification {
    CGRect keyboard_rect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboard_rect_cvt = [self.view convertRect:keyboard_rect fromView:nil];
//    _text_enter_view_bottom_constraint.constant = -(_text_enter_view.frame.origin.y - keyboard_rect_cvt.origin.y);
    _text_enter_view_bottom_constraint.constant = -(keyboard_rect.size.height - (keyboard_rect.origin.y - keyboard_rect_cvt.origin.y) + 5);
//    NSLog(@"Show kb size (cvt): {{%f, %f}, {%f, %f}", keyboard_rect_cvt.origin.x, keyboard_rect_cvt.origin.y, keyboard_rect_cvt.size.width, keyboard_rect_cvt.size.height);
//    NSLog(@"text_enter_view: {{%f, %f}, {%f, %f}", _text_enter_view.frame.origin.x, _text_enter_view.frame.origin.y, _text_enter_view.frame.size.width, _text_enter_view.frame.size.height);
//    NSLog(@"Show kb size: {{%f, %f}, {%f, %f}", keyboard_rect.origin.x, keyboard_rect.origin.y, keyboard_rect.size.width, keyboard_rect.size.height);
}
-(void)onKeyboardHide:(NSNotification*)notification {
    _text_enter_view_bottom_constraint.constant = 0;
//    NSLog(@"Hide kb size: {%f, %f}", keyboard_size.width, keyboard_size.height);
}

@end
