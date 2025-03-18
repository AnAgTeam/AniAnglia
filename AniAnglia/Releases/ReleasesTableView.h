//
//  ReleaseTableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 09.12.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ReleasesTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>
@property(nonatomic) BOOL trailing_action_disabled;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;
@end
