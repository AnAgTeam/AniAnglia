//
//  ProfileViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ProfileViewController : UIViewController

-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;
-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id;
-(instancetype)initWithMyProfile;
@end

