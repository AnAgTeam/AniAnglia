//
//  ReleasesPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 20.04.2025.
//

#ifndef ReleasesPageableDataProvider_h
#define ReleasesPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "PageableDataProvider.h"

@interface ReleasesPageableDataProvider : PageableDataProvider

+(NSString*)getSeasonNameFor:(anixart::Release::Season)category;
+(NSString*)getCategoryNameFor:(anixart::Release::Category)category;
+(NSString*)getStatusNameFor:(anixart::Release::Status)category;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages initialReleases:(std::vector<anixart::Release::Ptr>)releases;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
// clear all the data without reload
-(void)clear;
// clear all the data and reload
-(void)reload;
// reload, then reassign data
-(void)refresh;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Release::Ptr)getReleaseAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
// load page if isn't loaded yet. If loaded immediately calls delegate "didLoadedPageAtIndex:"
-(void)loadCurrentPageIfNeeded;
-(void)loadNextPage;

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index;

@end


#endif /* ReleasesPageableDataProvider_h */
