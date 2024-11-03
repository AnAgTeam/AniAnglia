//
//  TypeSelectViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import <UIKit/UIKit.h>

@interface TypeSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(instancetype)initWithReleaseID:(long long)release_id;
@end
