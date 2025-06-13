//
//  ReleasesViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#ifndef ReleasesViewController_h
#define ReleasesViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "ReleasesPageableDataProvider.h"

@interface ReleasesViewController : UIViewController
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;

-(void)reload;
-(void)refresh;

-(void)setHeaderView:(UIView*)header_view;

// can override in derived classes to change display
-(__kindof UIViewController<PageableDataProviderDelegate>*)getTableViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider;
-(__kindof UIViewController<PageableDataProviderDelegate>*)getCollectionViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider;
@end

#endif /* ReleasesViewController_h */
