//
//  EpisodeSelectViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import <UIKit/UIKit.h>

@interface EpisodeSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(instancetype)initWithReleaseID:(long long)release_id typeID:(long long)type_id typeName:(NSString*)type_name sourceID:(long long)source_id sourceName:(NSString*)source_name;
@end
