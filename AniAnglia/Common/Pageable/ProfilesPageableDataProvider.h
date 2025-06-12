//
//  ProfilesPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#ifndef ProfilesPageableDataProvider_h
#define ProfilesPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "PageableDataprovider.h"

@interface ProfilesPageableDataProvider : PageableDataProvider
-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages initialProfiles:(std::vector<anixart::Profile::Ptr>)profiles;

// clear all the data without reload
-(void)clear;
// reload, then reassign data
-(void)reset;
// clear all the data, set pages and load first
-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Profile::Ptr)getProfileAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
-(void)loadNextPage;

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index;

@end


#endif /* ProfilesPageableDataProvider_h */
