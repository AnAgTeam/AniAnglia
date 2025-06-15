//
//  ProfilesTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#import <Foundation/Foundation.h>
#import "ProfilesTableViewController.h"
#import "LoadableView.h"
#import "StringCvt.h"
#import "AppColor.h"
#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"

@interface ProfilesTableViewController () <UITableViewDataSourcePrefetching>
@property(nonatomic) BOOL is_first_loading;
@property(nonatomic, retain) ProfilesPageableDataProvider* data_provider;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UILabel* empty_label;
@property(nonatomic, retain) UIView* header_view;

@end

@implementation ProfilesTableViewController

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = [[ProfilesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    _is_first_loading = YES;
    
    [_data_provider loadCurrentPage];
    
    return self;
}

-(instancetype)initWithTableView:(UITableView*)table_view dataProvider:(ProfilesPageableDataProvider*)data_provider {
    self = [super init];
    
    _table_view = table_view;
    _data_provider = data_provider;
    _auto_page_load_disabled = NO;
    _is_container_view_controller = NO;
    _is_first_loading = NO;
    
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
}

-(void)setup {
    [_table_view registerClass:ProfileTableViewCell.class forCellReuseIdentifier:[ProfileTableViewCell getIdentifier]];
    _table_view.tableHeaderView = _header_view;
    
    _loadable_view = [LoadableView new];
    
    _empty_label = [UILabel new];
    _empty_label.text = NSLocalizedString(@"app.releases_table_view.is_empty_label.text", "");
    _empty_label.hidden = YES;
    
    [self.view addSubview:_loadable_view];
    [self.view addSubview:_empty_label];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        
        [_empty_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_empty_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_empty_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        [_empty_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    if (_is_first_loading) {
        [_loadable_view startLoading];
    }
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _empty_label.textColor = [AppColorProvider textColor];
}

-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}
-(void)setDataProvider:(ProfilesPageableDataProvider*)data_provider {
    // TODO: test
    _data_provider = data_provider;
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

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_provider getItemsCount];
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 70;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    NSInteger index = [index_path item];
    anixart::Profile::Ptr profile = [_data_provider getProfileAtIndex:index];
    
    return [self tableView:table_view cellForRowAtIndexPath:index_path withProfile:profile];
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path withProfile:(anixart::Profile::Ptr)profile {
    ProfileTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ProfileTableViewCell getIdentifier] forIndexPath:index_path];
    
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(profile->avatar_url)];
    
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(profile->username)];
    [cell setIsOnline:profile->is_online];
    
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
    anixart::Profile::Ptr profile = [_data_provider getProfileAtIndex:index];
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:profile->id] animated:YES];
}

-(void)tableViewDidLoad {
    
}

-(UIContextMenuConfiguration *)tableView:(UITableView *)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    return [_data_provider getContextMenuConfigurationForItemAtIndex:index_path.row];
}

-(void)didUpdateDataForPageableDataProvider:(PageableDataProvider*)pageable_data_provider {
    // reload sections causes constraints errors
    [_table_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadPageAtIndex:(NSInteger)page_index {
    if (_is_first_loading) {
        _is_first_loading = NO;
        [_loadable_view endLoading];
    }
    // reload sections causes constraints errors
    [_table_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didFailPageAtIndex:(NSInteger)page_index {
    // TODO
}

@end
