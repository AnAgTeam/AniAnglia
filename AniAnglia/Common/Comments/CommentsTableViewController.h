//
//  CommentsTableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.04.2025.
//

#ifndef CommentsTableView_h
#define CommentsTableView_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "CommentsPageableDataProvider.h"

@class CommentsTableViewCell;

@protocol CommentsTableViewCellDelegate <NSObject>
-(void)didShowRepliesPressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell;
-(void)didUpvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell;
-(void)didDownvotePressedForCommentTableViewCell:(CommentsTableViewCell*)comment_table_view_cell;
-(void)didReplyPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell;
-(void)didAvatarPressedCommentForTableViewCell:(CommentsTableViewCell*)comment_table_view_cell;
@end

@protocol CommentsTableViewControllerDelegate <NSObject>
-(void)didReplyPressedForCommentsTableView:(UITableView*)table_view comment:(anixart::Comment::Ptr)comment;

@optional
-(void)commentsTableView:(UITableView*)table_view didGotPageAtIndex:(NSInteger)page_index;
@optional
-(void)commentsTableView:(UITableView*)table_view didFailedPageAtIndex:(NSInteger)page_index;
@optional
-(void)commentsTableView:(UITableView*)table_view didEditContextMenuSelected:(anixart::Comment::Ptr)comment;
@end

@interface CommentsTableViewCell : UITableViewCell
@property(nonatomic, weak) id<CommentsTableViewCellDelegate> delegate;

+(NSString*)getIdentifier;

-(void)setAvatarUrl:(NSURL*)url;
-(void)setUsername:(NSString*)username;
-(void)setPublishDate:(NSString*)publish_date;
-(void)setContent:(NSString*)content;
-(void)setVoteCount:(NSInteger)vote_count;
-(void)setIsSpoiler:(BOOL)is_spoiler;
-(void)setIsEdited:(BOOL)is_edited;

-(void)setOrigin:(NSString*)origin name:(NSString*)name;
-(void)setRepliesCount:(NSInteger)replies_count;
@end

@interface CommentsTableViewController : UITableViewController <PageableDataProviderDelegate>
@property(nonatomic, weak) id<CommentsTableViewControllerDelegate> delegate;
@property(nonatomic) BOOL enable_origin_reference;
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Comment>::UPtr)pages;
//-(instancetype)initWithTableView:(UITableView*)table_view comments:(std::vector<anixart::Comment::Ptr>)comments;
-(instancetype)initWithTableView:(UITableView*)table_view dataProvider:(CommentsPageableDataProvider*)data_provider;

-(void)setPages:(anixart::Pageable<anixart::Comment>::UPtr)pages;
-(void)setDataProvider:(CommentsPageableDataProvider*)data_provider;
-(void)clear;
-(void)reload;
-(void)refresh;

-(void)setHeaderView:(UIView*)header_view;
-(void)setContentInsets:(UIEdgeInsets)insets;
-(CGPoint)getContentOffset;
-(void)setContentOffset:(CGPoint)point;
-(void)setKeyboardDismissMode:(UIScrollViewKeyboardDismissMode)dismiss_mode;

-(NSInteger)getCommentIndex:(anixart::CommentID)comment_id;
-(void)scrollToCommentAtIndex:(NSInteger)comment_index;
@end

#endif /* CommentsTableView_h */
