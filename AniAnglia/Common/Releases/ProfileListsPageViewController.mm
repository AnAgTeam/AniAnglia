//
//  ProfilesTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#import <Foundation/Foundation.h>
#import "ProfileListsPageViewController.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "SegmentedPageViewController.h"
#import "AppDataController.h"
#import "ReleasesViewController.h"
#import "ReleasesHistoryTableViewController.h"
#import "CollectionsCollectionViewController.h"

@interface ReleasesHistoryViewController : ReleasesViewController

@end


@interface ProfileListsPageViewController () {
    anixart::Profile::ListSort _lists_sort;
    anixart::ProfileID _profile_id;
}
@property(nonatomic) BOOL is_my_profile;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) SegmentedPageViewController* page_view_controller;

@end

@implementation ReleasesHistoryViewController

-(UIViewController<PageableDataProviderDelegate>*)getTableViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider {
    return [[ReleasesHistoryTableViewController alloc] initWithTableView:[UITableView new] releasesPageableDataProvider:data_provider];
}

@end

@implementation ProfileListsPageViewController

-(instancetype)initWithMyProfileID {
    return [self initWithProfileID:[[AppDataController sharedInstance] getMyProfileID]];
}
-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id {
    self = [super init];
    
    _profile_id = profile_id;
    _lists_sort = anixart::Profile::ListSort::Ascending;
    _is_my_profile = profile_id == [[AppDataController sharedInstance] getMyProfileID];
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _page_view_controller = [SegmentedPageViewController new];
    [_page_view_controller setPageViewControllers:[self getProfileListsViewControllers]];
    [_page_view_controller setSegmentTitles:[self getProfileListsNames]];
    [self addChildViewController:_page_view_controller];
    
    [self.view addSubview:_page_view_controller.view];
    
    _page_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_page_view_controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_page_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_page_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_page_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
   
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(NSArray<UIViewController*>*)getProfileListsViewControllers {
    NSMutableArray* view_controllers = [NSMutableArray arrayWithArray:@[
        [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_list(_profile_id,  anixart::Profile::ListStatus::Watching, _lists_sort, 0)],
        [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_list(_profile_id, anixart::Profile::ListStatus::Plan, _lists_sort, 0)],
        [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_list(_profile_id, anixart::Profile::ListStatus::Watched, _lists_sort, 0)],
        [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_list(_profile_id, anixart::Profile::ListStatus::HoldOn, _lists_sort, 0)],
        [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_list(_profile_id, anixart::Profile::ListStatus::Dropped, _lists_sort, 0)]
    ]];
    if (_is_my_profile) {
        [view_controllers insertObject:
         [[ReleasesViewController alloc] initWithPages:_api_proxy.api->releases().profile_favorites(_profile_id, _lists_sort, 0, 0)] atIndex:0];
        [view_controllers insertObject:[[ReleasesHistoryTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->releases().get_history(0)] atIndex:0];
        [view_controllers insertObject:[[CollectionsCollectionViewController alloc] initWithPages:_api_proxy.api->collections().my_favorite_collections(0) axis:UICollectionViewScrollDirectionVertical] atIndex:0];
    }
    return view_controllers;
}

-(NSArray<NSString*>*)getProfileListsNames {
    NSMutableArray* lists_names = [NSMutableArray arrayWithArray:@[
        NSLocalizedString(@"app.profile.list_status.watching", ""),
        NSLocalizedString(@"app.profile.list_status.plan", ""),
        NSLocalizedString(@"app.profile.list_status.watched", ""),
        NSLocalizedString(@"app.profile.list_status.holdon", ""),
        NSLocalizedString(@"app.profile.list_status.dropped", "")
    ]];
    if (_is_my_profile) {
        [lists_names insertObject:NSLocalizedString(@"app.profile.lists.favorite", "") atIndex:0];
        [lists_names insertObject:NSLocalizedString(@"app.profile.lists.history", "") atIndex:0];
        [lists_names insertObject:NSLocalizedString(@"app.profile.lists.collections", "") atIndex:0];
    }
    return lists_names;
}

//-(NSInteger)getPageCount {
//    return 0;
//}
//-(UIViewController*)getViewControllerForPageAtIndex:(NSInteger)index {
//
//}

@end
