//
//  ReleaseTableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 09.12.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@class ReleasesTableView;

@protocol ReleasesTableViewDelegate
-(void)releasesTableView:(ReleasesTableView*)releases_table_view didSelectReleaseAtIndex:(NSInteger)index;
@end

@protocol ReleasesTableViewDataSource
-(void)releasesTableView:(ReleasesTableView*)releases_table_view loadPage:(NSUInteger)page completionHandler:(void(^)(BOOL action_performed))completion_handler;
-(void)releasesTableView:(ReleasesTableView*)releases_table_view loadNextPageWithcompletionHandler:(void(^)(BOOL should_continue_fetch))completion_handler;
-(NSUInteger)numberOfItemsForReleasesTableView:(ReleasesTableView*)releases_table_view;
-(libanixart::Release::Ptr)releasesTableView:(ReleasesTableView*)releases_table_view releaseAtIndex:(NSUInteger)index;
@end

@interface ReleasesTableView : UIView <UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak, setter = setDataSource:) id<ReleasesTableViewDataSource> data_source;
@property(nonatomic, weak) id<ReleasesTableViewDelegate> delegate;

-(void)releasesTableViewDidShow;
@end

