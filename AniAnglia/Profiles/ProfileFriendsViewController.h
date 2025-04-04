//
//  ProfileFriendsViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#ifndef ProfileFriendsViewController_h
#define ProfileFriendsViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ProfileFriendsViewController : UIViewController

-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id;
@end

#endif /* ProfileFriendsViewController_h */
