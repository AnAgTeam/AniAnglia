//
//  ProfilesPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#ifndef ProfilesPageableDataProvider_h
#define ProfilesPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@class ProfilesPageableDataProvider;

@protocol ProfilesPageableDataProviderDelegate <NSObject>
-(void)didUpdatedDataForProfilesPageableDataProvider:(ProfilesPageableDataProvider*)profiles_pageable_data_provider;
@end

@interface ProfilesPageableDataProvider : NSObject
@property(nonatomic, weak) id<ProfilesPageableDataProviderDelegate> delegate;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;

-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;
-(void)reset;

-(BOOL)isEnd;
-(size_t)getItemsCount;
-(anixart::Profile::Ptr)getProfileAtIndex:(NSInteger)index;

-(void)loadCurrentPage;
-(void)loadNextPage;

@end


#endif /* ProfilesPageableDataProvider_h */
