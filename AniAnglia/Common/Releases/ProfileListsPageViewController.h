//
//  ProfileListsPageViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#ifndef ProfileListsPageViewController_h
#define ProfileListsPageViewController_h

#import <UIKit/UIKit.h>
#import "ReleasesPageableDataProvider.h"

@interface ProfileListsPageViewController : UIViewController

-(instancetype)initWithMyProfileID;
-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id;

@end

#endif /* ProfileListsPageViewController_h */
