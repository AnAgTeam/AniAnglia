//
//  CollectionsPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 15.06.2025.
//

#ifndef CollectionsPageableDataProvider_h
#define CollectionsPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "PageableDataProvider.h"

@interface CollectionsPageableDataProvider : PageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages initialCollections:(std::vector<anixart::Collection::Ptr>)collections;

-(void)setPages:(anixart::Pageable<anixart::Collection>::UPtr)pages;
// clear all the data without reload
-(void)clear;
// clear all the data and reload
-(void)reload;
// reload, then reassign data
-(void)refresh;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Collection::Ptr)getCollectionAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
// load page if isn't loaded yet. If loaded immediately calls delegate "didLoadedPageAtIndex:"
-(void)loadCurrentPageIfNeeded;
-(void)loadNextPage;

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index;

@end

#endif /* CollectionsPageableDataProvider_h */
