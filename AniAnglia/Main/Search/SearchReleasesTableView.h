//
//  SearchReleasesView.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <UIKit/UIKit.h>
#import "NavSearchViewController.h"
#import "ReleasesTableView.h"

@class SearchReleasesTableView;

@protocol SearchReleasesTableViewDataSource <ReleasesTableViewDataSource>
-(void)searchReleasesTableView:(SearchReleasesTableView*)releases_view willBeginRequestsWithQuery:(NSString*)query;
@end

@protocol SearchReleasesTableViewDelegate <ReleasesTableViewDelegate>

@end

@interface SearchReleasesTableView : NavigationSearchView
@property(nonatomic, weak, setter = setDataSource:) id<SearchReleasesTableViewDataSource> data_source;
@property(nonatomic, weak) id<SearchReleasesTableViewDelegate> delegate;
@property(nonatomic, retain) ReleasesTableView* releases_table_view;
@end
