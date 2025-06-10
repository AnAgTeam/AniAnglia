//
//  ReleasesPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 20.04.2025.
//

#ifndef ReleasesPageableDataProvider_h
#define ReleasesPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@class ReleasesPageableDataProvider;

@protocol ReleasesPageableDataProviderDelegate <NSObject>
-(void)didUpdatedDataForReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

@optional
-(void)releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider didLoadedPageWithIndex:(NSInteger)page_index;
@end

@interface ReleasesPageableDataProvider : NSObject
@property(nonatomic, weak) id<ReleasesPageableDataProviderDelegate> delegate;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages initialReleases:(std::vector<anixart::Release::Ptr>)releases;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Release::Ptr)getReleaseAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
-(void)loadNextPage;

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index;

@end


#endif /* ReleasesPageableDataProvider_h */
