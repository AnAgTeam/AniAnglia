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
#import "ProfilesPageableDataProvider.h"

@interface ProfileFriendsViewController : UIViewController <ProfilesPageableDataProviderDelegate>

-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id isMyProfile:(BOOL)is_my_profile;
@end

#endif /* ProfileFriendsViewController_h */
