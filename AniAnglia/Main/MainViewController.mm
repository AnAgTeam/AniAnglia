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
#import "ReleasesViewController.h"

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
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, std::nullopt)],
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Ongoing, std::nullopt)],
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Upcoming, std::nullopt)],
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, anixart::Release::Status::Finished, std::nullopt)],
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Movies)],
       [[ReleasesViewController alloc] initWithPages:construct_filter_request_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Ova)]
   ]];
    [_page_view_controler setSegmentTitles:@[
        NSLocalizedString(@"app.pages.releases.actual", ""),
        NSLocalizedString(@"app.pages.releases.ongoing", ""),
        NSLocalizedString(@"app.pages.releases.upcoming", ""),
        NSLocalizedString(@"app.pages.releases.finished", ""),
        NSLocalizedString(@"app.pages.releases.movies", ""),
        NSLocalizedString(@"app.pages.releases.ova", "")
    ]];
    
    [self addChildViewController:_page_view_controler];
    
    [self.view addSubview:_page_view_controler.view];
    
    _page_view_controler.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_page_view_controler.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_page_view_controler.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_page_view_controler.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_page_view_controler.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

@end
