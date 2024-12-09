//
//  MainViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <UIKit/UIKit.h>
#import "NavSearchViewController.h"
#import "ReleasesSearchHistoryView.h"
#import "SearchReleasesTableView.h"

@interface MainViewController : NavigationSearchViewController <NavigationSearchDelegate, SearchReleasesTableViewDelegate, SearchReleasesTableViewDataSource>

@end
