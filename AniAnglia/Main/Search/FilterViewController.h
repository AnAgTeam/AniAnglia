//
//  FilterViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.12.2024.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "ReleasesHistoryTableViewController.h"

@interface FilterViewController : UIViewController <SearchViewControllerDataSource, SearchViewControllerDelegate, ReleasesHistoryTableViewControllerDelegate>

@end
