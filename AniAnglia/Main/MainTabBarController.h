//
//  MainTabBarController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "ReleasesSearchHistoryTableViewController.h"

@interface MainTabBarController : UITabBarController <SearchViewControllerDataSource, SearchViewControllerDelegate, ReleasesSearchHistoryTableViewControllerDelegate>
@property(nonatomic, retain) UINavigationController* main_nav_controller;
@property(nonatomic, retain) UINavigationController* discover_nav_controller;
@property(nonatomic, retain) UINavigationController* bookmarks_nav_controller;
@property(nonatomic, retain) UINavigationController* profile_nav_controller;

-(instancetype)init;

@end
