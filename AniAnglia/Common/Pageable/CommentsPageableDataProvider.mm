//
//  CommentsPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#import <Foundation/Foundation.h>
#import "CommentsPageableDataProvider.h"
#import "AppDataController.h"
#import "StringCvt.h"

@interface CommentsPageableDataProvider () {
    anixart::ProfileID _my_profile_id;
    anixart::Pageable<anixart::Comment>::UPtr _pages;
    std::vector<anixart::Comment::Ptr> _comments;
}
@property(nonatomic, copy) void(^edit_handler)(anixart::Comment::Ptr comment);

@end

@implementation CommentsPageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages{
    self = [super init];
    
    _my_profile_id = [[AppDataController sharedInstance] getMyProfileID];
    _pages = std::move(pages);
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Comment>::UPtr)pages initialComments:(std::vector<anixart::Comment::Ptr>)comments {
    self = [self initWithPages:std::move(pages)];
    
    _comments = std::move(comments);
    
    return self;
}

-(void)clear {
    // TODO: load cancel
    _comments.clear();
    [self callDelegateDidUpdated];
}
-(void)reset {
    [self loadPageAtIndex:0];
}

-(void)setPages:(anixart::Pageable<anixart::Comment>::UPtr)pages {
    _comments.clear();
    _pages = std::move(pages);
    [self callDelegateDidUpdated];
    [self loadCurrentPage];
}

-(BOOL)isEnd {
    return _pages->is_end();
}
-(size_t)getItemsCount {
    return _comments.size();
}
-(NSInteger)getCommentIndex:(anixart::CommentID)comment_id {
    // TODO: maybe unefficient, due to vector of shared_ptr's. If it's a problem, will need to improve libanixart
    auto iter = std::find_if(_comments.begin(), _comments.end(), [comment_id](anixart::Comment::Ptr& comment) {
        return comment->id == comment_id;
    });
    return iter != _comments.end() ? std::distance(_comments.begin(), iter) : NSNotFound;
}
-(anixart::Comment::Ptr)getCommentAtIndex:(NSInteger)index {
    if (index >= _comments.size()) {
        // wtf
        return nullptr;
    }
    return _comments[index];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Comment::Ptr>(^)())block {
    [self setItemsFromBlock:block isAppend:YES];
}

-(void)setItemsFromBlock:(std::vector<anixart::Comment::Ptr>(^)())block isAppend:(BOOL)is_append {
    if (!_pages) {
        return;
    }
    
    __block decltype(block()) new_items;
    [self.api_proxy asyncCall:^BOOL(anixart::Api* api) {
        new_items = block();
        return NO;
    } completion:^(BOOL errored) {
        if (errored) {
            [self callDelegateDidFailedPageAtIndex:self->_pages->get_current_page()];
            return;
        }
        if (is_append) {
            self->_comments.insert(self->_comments.end(), new_items.begin(), new_items.end());
        } else {
            self->_comments = std::move(new_items);
        }
        [self callDelegateDidLoadedPageAtIndex:self->_pages->get_current_page()];
    }];
}

-(void)loadCurrentPage {
    [self appendItemsFromBlock:^() {
        return self->_pages->get();
    }];
}
-(void)loadNextPage {
    if (_pages->is_end()) {
        return;
    }
    [self appendItemsFromBlock:^() {
        return self->_pages->next();
    }];
}
-(void)loadPageAtIndex:(NSInteger)index {
    __strong auto strong_self = self;
    [self setItemsFromBlock:^() {
        return strong_self->_pages->go(static_cast<int32_t>(index));
    } isAppend:NO];
}

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index{
    if (index >= _comments.size()) {
        return nil;
    }
    anixart::Comment::Ptr comment = _comments[index];
    
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

-(void)setEditHandler:(void(^)(anixart::Comment::Ptr comment))handler {
    _edit_handler = handler;
}
-(void)setReportHandler:(void(^)(anixart::Comment::Ptr comment))handler {
    // TODO
}

-(void)onCopyTextContextMenuItemSelectedAtIndex:(NSInteger)index {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(_comments[index]->message);
}
-(void)onEditContextMenuItemSelectedAtIndex:(NSInteger)index {
    if (_edit_handler) {
        anixart::Comment::Ptr& comment = _comments[index];
        _edit_handler(comment);
    }
}
-(void)onRemoveContextMenuItemSelectedAtIndex:(NSInteger)index {
    anixart::Comment::Ptr comment = _comments[index];
    BOOL is_release_comment = comment->release ? YES : NO;
    
    [self.api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (is_release_comment) {
            api->releases().remove_release_comment(comment->id);
        } else {
            api->collections().remove_comment(comment->id);
        }
        return YES;
    } withUICompletion:^{
        [self callDelegateDidUpdated];
    }];
}
-(void)onReportContextMenuItemSelectedAtIndex:(NSInteger)index {
    // TODO
}

@end
