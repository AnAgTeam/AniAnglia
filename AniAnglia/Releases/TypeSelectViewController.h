//
//  TypeSelectViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface TypeSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id;
@end
