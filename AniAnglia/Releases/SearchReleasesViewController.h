//
//  SearchReleasesViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@protocol SearchReleasesViewDataSource
-(libanixart::Release::Ptr)getReleaseAtIndex:(NSUInteger)index;
@end

@interface SearchReleasesView : UIView
@property(nonatomic, weak, setter = setDataSource:) id<SearchReleasesViewDataSource> data_source;

@end
