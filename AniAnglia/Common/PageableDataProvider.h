//
//  GenericPageableDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#ifndef GenericPageableDataProvider_h
#define GenericPageableDataProvider_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@class PageableDataProvider;

@protocol PageableDataProviderDelegate <NSObject>

-(void)didUpdatedDataForPageableDataProvider:(PageableDataProvider*)pageable_data_provider;

@optional
-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadedPageAtIndex:(NSInteger)page_index;
@optional
-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didFailedPageAtIndex:(NSInteger)page_index;

@end

@interface PageableDataProvider : NSObject
@property(nonatomic, weak) id<PageableDataProviderDelegate> delegate;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) NSLock* lock;

-(instancetype)init;

-(void)callDelegateDidUpdated;
-(void)callDelegateDidLoadedPageAtIndex:(NSInteger)index;
-(void)callDelegateDidFailedPageAtIndex:(NSInteger)index;

@end


#endif /* GenericPageableDataProvider_h */
