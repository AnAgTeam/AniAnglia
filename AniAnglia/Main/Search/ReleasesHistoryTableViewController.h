//
//  HistoryTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>

@class ReleasesHistoryTableViewController;

@protocol ReleasesHistoryTableViewControllerDelegate <NSObject>
-(void)releasesHistoryTableViewController:(ReleasesHistoryTableViewController*)history_table_view_controller didSelectHistoryItem:(NSString*)item_name;
@end

@interface ReleasesHistoryTableViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak) id<ReleasesHistoryTableViewControllerDelegate> delegate;

@end
