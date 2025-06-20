//
//  SearchViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "ReleasesPageableDataProvider.h"
#import "ReleaseTableViewCell.h"

// Always automatically sets delegate for "PageableDataProviderDelegate"
@interface ReleasesTableViewController : UITableViewController <PageableDataProviderDelegate>
@property(nonatomic) BOOL is_container_view_controller;
@property(nonatomic) BOOL auto_page_load_disabled;

-(instancetype)initWithTableView:(UITableView*)table_view;
-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithTableView:(UITableView*)table_view releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)setReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

-(void)reload;
-(void)refresh;

-(void)reloadData;

-(void)setHeaderView:(UIView*)header_view;

// can override in derived classes to change cell display
-(void)tableViewDidLoad;
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path;
-(__kindof UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path withRelease:(anixart::Release::Ptr)release;
@end
