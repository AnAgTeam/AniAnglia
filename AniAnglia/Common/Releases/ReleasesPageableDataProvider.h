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

@protocol ReleasesPageableDataProviderDelegate
-(void)releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider didLoadedPageWithIndex:(NSInteger)page_index;
@end

@interface ReleasesPageableDataProvider : NSObject
@property(nonatomic, weak) id<ReleasesPageableDataProviderDelegate> delegate;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Release::Ptr)getReleaseAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
-(void)loadNextPage;

@end


#endif /* ReleasesPageableDataProvider_h */
