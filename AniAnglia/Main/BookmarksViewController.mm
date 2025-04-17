//
//  BookmarksViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "BookmarksViewController.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "SegmentedPageViewController.h"
#import "LibanixartApi.h"
#import "ReleasesTableViewController.h"
#import "AppDataController.h"

anixart::ProfileListPages::UPtr create_list_pages(anixart::Api* api, anixart::Profile::ListStatus list) {
    return api->releases().my_profile_list(list, anixart::Profile::ListSort::Ascending, 0);
}

@interface BookmarksViewController () {
    anixart::ProfileID _my_profile_id;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, retain) SegmentedPageViewController* page_view_controller;
@end

@implementation BookmarksViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    _my_profile_id = [_app_data_controller getMyProfileID];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _page_view_controller = [SegmentedPageViewController new];
    [_page_view_controller setPageViewControllers:@[
        [self makeHistoryViewController],
        [[ReleasesTableViewController alloc] initWithPages:_api_proxy.api->releases().profile_favorites(_my_profile_id, anixart::Profile::ListSort::Ascending, 0, 0) trailingActionDisabled:YES],
        [[ReleasesTableViewController alloc] initWithPages:create_list_pages(_api_proxy.api, anixart::Profile::ListStatus::Watching) trailingActionDisabled:YES],
        [[ReleasesTableViewController alloc] initWithPages:create_list_pages(_api_proxy.api, anixart::Profile::ListStatus::Plan) trailingActionDisabled:YES],
        [[ReleasesTableViewController alloc] initWithPages:create_list_pages(_api_proxy.api, anixart::Profile::ListStatus::Watched) trailingActionDisabled:YES],
        [[ReleasesTableViewController alloc] initWithPages:create_list_pages(_api_proxy.api, anixart::Profile::ListStatus::HoldOn) trailingActionDisabled:YES],
        [[ReleasesTableViewController alloc] initWithPages:create_list_pages(_api_proxy.api, anixart::Profile::ListStatus::Dropped) trailingActionDisabled:YES]
    ]];
    [_page_view_controller setSegmentTitles:@[
        NSLocalizedString(@"app.bookmarks.history.title", ""),
        NSLocalizedString(@"app.bookmarks.favorites.title", ""),
        NSLocalizedString(@"app.bookmarks.watching.title", ""),
        NSLocalizedString(@"app.bookmarks.plan.title", ""),
        NSLocalizedString(@"app.bookmarks.watched.title", ""),
        NSLocalizedString(@"app.bookmarks.holdon.title", ""),
        NSLocalizedString(@"app.bookmarks.dropped.title", ""),
    ]];
    [self addChildViewController:_page_view_controller];
    
    [self.view addSubview:_page_view_controller.view];
    
    _page_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_page_view_controller.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_page_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_page_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_page_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
   
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(UIViewController*)makeHistoryViewController {
    return [[ReleasesTableViewController alloc] initWithPages:_api_proxy.api->releases().get_history(0) trailingActionDisabled:YES];
}

@end
