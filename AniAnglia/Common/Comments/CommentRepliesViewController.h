//
//  CommentsReplyTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 14.04.2025.
//

#ifndef CommentsReplyTableViewController_h
#define CommentsReplyTableViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface CommentRepliesViewController : UIViewController

-(instancetype)initWithComment:(anixart::Comment::Ptr)comment;
-(instancetype)initWithReplyToComment:(anixart::Comment::Ptr)comment;
@end

#endif /* CommentsReplyTableViewController_h */
