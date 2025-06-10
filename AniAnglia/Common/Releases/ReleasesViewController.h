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
-(void)reset;

-(void)setHeaderView:(UIView*)header_view;
@end

#endif /* ReleasesViewController_h */
