//
//  SearchViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "ReleasesPageableDataProvider.h"

@interface ReleasesTableViewController : UIViewController <ReleasesPageableDataProviderDelegate>
@property(nonatomic) BOOL is_container_view_controller;
@property(nonatomic) BOOL trailing_action_disabled;
@property(nonatomic) BOOL auto_page_load_disabled;

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithTableView:(UITableView*)table_view releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;

-(void)reloadData;

-(void)setHeaderView:(UIView*)header_view;
@end
