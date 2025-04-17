//
//  ReleaseViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 29.08.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ReleaseViewController : UIViewController

-(instancetype)initWithRelease:(anixart::Release::Ptr)release;
-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id;
-(instancetype)initWithRandomRelease;

@end
