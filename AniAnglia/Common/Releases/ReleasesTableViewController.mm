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

@interface ReleasesTableViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching>
@property(nonatomic, retain) ReleasesPageableDataProvider* data_provider;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UILabel* empty_label;
@property(nonatomic, retain) UIView* header_view;

@end

@implementation ReleasesTableViewController

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    _trailing_action_disabled = NO;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    
    return self;
}
-(instancetype)initWithTableView:(UITableView*)table_view releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = releases_pageable_data_provider;
    _trailing_action_disabled = NO;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    if (!_table_view) {
        _table_view = [UITableView new];
    }
    [_table_view registerClass:ReleaseTableViewCell.class forCellReuseIdentifier:[ReleaseTableViewCell getIdentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    _table_view.tableHeaderView = _header_view;
    
    _loadable_view = [LoadableView new];
    
    _empty_label = [UILabel new];
    _empty_label.text = NSLocalizedString(@"app.releases_table_view.is_empty_label.text", "");
    _empty_label.hidden = YES;
    
    [self.view addSubview:_table_view];
    [self.view addSubview:_loadable_view];
    [self.view addSubview:_empty_label];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    if (_is_container_view_controller) {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            
            [_empty_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.topAnchor],
            [_empty_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor],
            [_empty_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor],
            [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [_empty_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
            
            [_empty_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_empty_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_empty_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
            [_empty_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
        ]];
    }

}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _empty_label.textColor = [AppColorProvider textColor];
}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}
-(void)reset {
    /* TODO: */
    [_data_provider reset];
    [_table_view reloadData];
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

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_provider getItemsCount];
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 175;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    ReleaseTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleaseTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Release::Ptr release = [_data_provider getReleaseAtIndex:index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setDescription:TO_NSSTRING(release->description)];
    [cell setEpCount:release->episodes_released];
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

-(UISwipeActionsConfiguration*)tableView:(UITableView*)table_view trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath*)index_path {
    if (_trailing_action_disabled) {
        return nil;
    }
    
    UIContextualAction* bookmark_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL action_performed)) {
        [self onAddToBookmarkTrailingActionAtindexPath:index_path];
        completion_handler(YES);
    }];
    bookmark_action.backgroundColor = [UIColor systemYellowColor];
    bookmark_action.image = [UIImage systemImageNamed:@"bookmark"];
    
    UIContextualAction* add_to_list_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL action_performed)){
        [self onAddToListTrailingActionAtindexPath:index_path];
        completion_handler(YES);
    }];
    add_to_list_action.image = [UIImage systemImageNamed:@"line.3.horizontal"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[
        bookmark_action,
        add_to_list_action
    ]];
}

-(void)onAddToBookmarkTrailingActionAtindexPath:(NSIndexPath*)index_path {
    
}
-(void)onAddToListTrailingActionAtindexPath:(NSIndexPath*)index_path  {
    
}

-(void)releasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider didLoadedPageWithIndex:(NSInteger)page_index {
    [_table_view reloadData];
}

@end
