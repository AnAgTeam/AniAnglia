//
//  SourceSelectViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface SourceSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id typeID:(anixart::EpisodeTypeID)type_id typeName:(NSString*)type_name;
@end
