//
//  ProfileTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#ifndef ProfileTableViewController_h
#define ProfileTableViewController_h

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setAvatarUrl:(NSURL*)url;
-(void)setUsername:(NSString*)username;
-(void)setFriendCount:(NSString*)friend_count;
-(void)setIsOnline:(BOOL)is_online;

@end

#endif /* ProfileTableViewController_h */
