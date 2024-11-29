//
//  SearchReleasesView.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "NavSearchViewController.h"

@class SearchReleasesView;

@protocol SearchReleasesViewDelegate
-(void)searchReleasesView:(SearchReleasesView*)releases_view didSelectReleaseAtIndex:(NSInteger)index;
@end

@protocol SearchReleasesViewDataSource
-(void)willBeginRequestsWithQuery:(NSString*)query;
-(void)searchReleasesView:(SearchReleasesView*)releases_view loadPage:(NSUInteger)page completionHandler:(void(^)(BOOL action_performed))completion_handler;
-(void)searchReleasesView:(SearchReleasesView*)releases_view loadNextPageWithcompletionHandler:(void(^)(BOOL should_continue_fetch))completion_handler;
-(NSUInteger)numberOfItemsForSearchReleasesView:(SearchReleasesView*)releases_view;
-(libanixart::Release::Ptr)searchReleasesView:(SearchReleasesView*)releases_view releaseAtIndex:(NSUInteger)index;
@end

@interface SearchReleasesView : NavigationSearchView <UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak, setter = setDataSource:) id<SearchReleasesViewDataSource> data_source;
@property(nonatomic, weak) id<SearchReleasesViewDelegate> delegate;

@end
