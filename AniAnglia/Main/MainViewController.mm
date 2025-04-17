//
//  MainViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "ReleaseViewController.h"
#import "StringCvt.h"
#import "ReleasesTableViewController.h"

anixart::FilterPages::UPtr construct_filter_request_pages(anixart::Api* api, const std::optional<anixart::Release::Status> status, const std::optional<anixart::Release::Category> category) {
    anixart::requests::FilterRequest filter_request;
    filter_request.status = status;
    filter_request.category = category;
    return api->search().filter_search(filter_request, false, 0);
}

@interface MainViewController () <UISearchBarDelegate>
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) SegmentedPageViewController* page_view_controler;

@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _page_view_controler = [SegmentedPageViewController new];
    [_page_view_controler setPageViewControllers:@[
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, std::nullopt) trailingActionDisabled:YES],
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Ongoing, std::nullopt) trailingActionDisabled:YES],
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Upcoming, std::nullopt) trailingActionDisabled:YES],
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Finished, std::nullopt) trailingActionDisabled:YES],
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Movies) trailingActionDisabled:YES],
       [[ReleasesTableViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Ova) trailingActionDisabled:YES]
   ]];
    [_page_view_controler setSegmentTitles:@[
        NSLocalizedString(@"app.main.pages_segment_control.actual.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.ongoing.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.upcoming.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.finished.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.movies.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.ova.name", "")
    ]];
    
    [self addChildViewController:_page_view_controler];
    
    [self.view addSubview:_page_view_controler.view];
    
    _page_view_controler.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_page_view_controler.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_page_view_controler.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_page_view_controler.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_page_view_controler.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

@end
