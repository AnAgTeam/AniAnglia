//
//  SearchViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "ReleasesHistoryTableViewController.h"

@interface ReleasesTableViewController : UIViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages trailingActionEnabled:(BOOL)trailing_action_enabled;
-(void)updatePages:(anixart::Pageable<anixart::Release>::UPtr)pages;
@end
