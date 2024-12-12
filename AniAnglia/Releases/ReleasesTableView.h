//
//  ReleaseTableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 09.12.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "NavSearchViewController.h"

@interface ReleasesTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>
@property(nonatomic) BOOL trailing_action_disabled;

-(instancetype)initWithPages:(libanixart::Pageable<libanixart::Release>::UniqPtr)pages;
-(void)setPages:(libanixart::Pageable<libanixart::Release>::UniqPtr)pages;
-(void)reset;
@end
