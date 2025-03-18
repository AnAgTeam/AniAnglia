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
-(void)updatePages:(anixart::Pageable<anixart::Release>::UPtr)pages;
@end
