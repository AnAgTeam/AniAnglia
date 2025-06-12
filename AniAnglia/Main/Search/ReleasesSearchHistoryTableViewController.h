//
//  HistoryTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>

@class ReleasesSearchHistoryTableViewController;

@protocol ReleasesSearchHistoryTableViewControllerDelegate <NSObject>
-(void)releasesSearchHistoryTableViewController:(ReleasesSearchHistoryTableViewController*)search_history_table_view_controller didSelectHistoryItem:(NSString*)item_name;
@end

@interface ReleasesSearchHistoryTableViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak) id<ReleasesSearchHistoryTableViewControllerDelegate> delegate;

@end
