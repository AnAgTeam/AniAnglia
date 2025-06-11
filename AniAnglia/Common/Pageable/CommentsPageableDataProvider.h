//
//  CommentsPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#ifndef CommentsPageableDataProvider_h
#define CommentsPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "PageableDataProvider.h"

@interface CommentsPageableDataProvider : PageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages initialComments:(std::vector<anixart::Comment::Ptr>)comments;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages initialComments:(std::vector<anixart::Comment::Ptr>)comments;

// clear all the data without reload
-(void)clear;
// reload, then reassign data
-(void)reset;
// clear all the data, set pages and load first
-(void)setPages:(anixart::Pageable<anixart::Comment>::UPtr)pages;

-(BOOL)isEnd ;
-(size_t)getItemsCount;
-(NSInteger)getCommentIndex:(anixart::CommentID)comment_id;
-(anixart::Comment::Ptr)getCommentAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
-(void)loadNextPage;

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index;

-(void)setEditHandler:(void(^)(anixart::Comment::Ptr comment))handler;
-(void)setReportHandler:(void(^)(anixart::Comment::Ptr comment))handler;

@end


#endif /* CommentsPageableDataProvider_h */
