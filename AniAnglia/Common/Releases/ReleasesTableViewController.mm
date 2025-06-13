//
//  SearchViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesTableViewController.h"
#import "ReleaseTableViewCell.h"
#import "FilterViewController.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "LoadableView.h"
#import "ReleaseViewController.h"

@interface ReleasesTableViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching, LoadableViewDelegate>
@property(nonatomic) BOOL is_first_loading;
@property(nonatomic, retain) ReleasesPageableDataProvider* data_provider;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UILabel* empty_label;
@property(nonatomic, retain) UIView* header_view;
@property(nonatomic, retain) UIRefreshControl* refresh_control;

@end

@implementation ReleasesTableViewController

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    _is_first_loading = YES;
    
    return self;
}


-(instancetype)initWithTableView:(UITableView*)table_view releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = releases_pageable_data_provider;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    _is_first_loading = YES;
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    if (!_table_view) {
        _table_view = [UITableView new];
    }
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    _table_view.contentInsetAdjustmentBehavior = _is_container_view_controller ? UIScrollViewContentInsetAdjustmentNever : UIScrollViewContentInsetAdjustmentAutomatic;
    
    self.view = _table_view;
    self.tableView = _table_view;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    
    [self tableViewDidLoad];
    if (_is_first_loading && _data_provider.is_needed_first_load) {
        [_loadable_view startLoading];
        [_data_provider loadCurrentPage];
    }
}

-(void)setup {
    [_table_view registerClass:ReleaseTableViewCell.class forCellReuseIdentifier:[ReleaseTableViewCell getIdentifier]];
    _table_view.tableHeaderView = _header_view;
    
    _refresh_control = [UIRefreshControl new];
    [_refresh_control addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    _loadable_view = [LoadableView new];
    _loadable_view.delegate = self;
    
    _empty_label = [UILabel new];
    _empty_label.text = NSLocalizedString(@"app.common.load_empty", "");
    _empty_label.hidden = YES;
    
    [self.view addSubview:_loadable_view];
    [self.view addSubview:_empty_label];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor],
        
        [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor],
    ]];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _empty_label.textColor = [AppColorProvider textColor];
}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}

-(void)setReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider {
    // TODO: test
    _data_provider = releases_pageable_data_provider;
    [self reloadData];
}

-(void)reload {
    [_data_provider reload];
}

-(void)refresh {
    [_data_provider refresh];
}

-(void)reloadData {
    [_table_view reloadData];
}

-(void)setHeaderView:(UIView*)header_view {
    _header_view = header_view;
    if (_table_view) {
        _table_view.tableHeaderView = header_view;
    }
}

-(void)setIsEmpty:(BOOL)is_empty {
    _empty_label.hidden = !is_empty;
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_provider getItemsCount];
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 175;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    NSInteger index = [index_path item];
    anixart::Release::Ptr release = [_data_provider getReleaseAtIndex:index];
    
    return [self tableView:table_view cellForRowAtIndexPath:index_path withRelease:release];
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path withRelease:(anixart::Release::Ptr)release {
    ReleaseTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleaseTableViewCell getIdentifier] forIndexPath:index_path];
    
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setDescription:TO_NSSTRING(release->description)];
    [cell setEpCount:release->episodes_released totalEpCount:release->episodes_total];
    [cell setRating:release->grade];
    [cell setImageUrl:image_url];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if ([_data_provider isEnd] || _auto_page_load_disabled) {
        return;
    }
    NSUInteger item_count = [_table_view numberOfRowsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [_data_provider loadNextPage];
            return;
        }
    }
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::Release::Ptr release = [_data_provider getReleaseAtIndex:index];
    
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}

-(void)tableViewDidLoad {
    
}

-(UIContextMenuConfiguration *)tableView:(UITableView *)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    return [_data_provider getContextMenuConfigurationForItemAtIndex:index_path.row];
}

-(void)didUpdatedDataForPageableDataProvider:(PageableDataProvider*)pageable_data_provider {
    // TODO: check if pages is changed
    // reload sections causes constraints errors
    [_table_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadedPageAtIndex:(NSInteger)page_index {
    [_loadable_view endLoading];
    _table_view.refreshControl = _refresh_control;
    
    if (_refresh_control.refreshing) {
        [_refresh_control endRefreshing];
    }
    if ([_data_provider getItemsCount] == 0) {
        [self setIsEmpty:YES];
    }
    // reload sections causes constraints errors
    [_table_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didFailedPageAtIndex:(NSInteger)page_index {
    if (_refresh_control.refreshing) {
        [_data_provider clear];
        [_refresh_control endRefreshing];
        _table_view.refreshControl = nil;
    }
    [_loadable_view endLoadingWithErrored:YES];
}

-(void)didReloadForLoadableView:(LoadableView*)loadable_view {
    [loadable_view startLoading];
    [_data_provider reload];
}

-(IBAction)onRefresh:(UIRefreshControl*)sender {
    [_data_provider refresh];
}

@end
