//
//  ProfilesTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#ifndef ProfilesTableViewController_h
#define ProfilesTableViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "ProfilesPageableDataProvider.h"

@interface ProfileTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setAvatarUrl:(NSURL*)url;
-(void)setUsername:(NSString*)username;
-(void)setFriendCount:(NSString*)friend_count;
-(void)setIsOnline:(BOOL)is_online;

@end

@interface ProfilesTableViewController : UIViewController <ProfilesPageableDataProviderDelegate>
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Profile>::UPtr)pages;

-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;
-(void)reset;

-(void)setHeaderView:(UIView*)header_view;

@end


#endif /* ProfilesTableViewController_h */
