//
//  ReleasesPopularPageViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 15.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesPopularPageViewController.h"
#import "ReleasesViewController.h"

anixart::FilterPages::UPtr make_popular_pages(anixart::Api* api, const std::optional<anixart::Release::Status> status, const std::optional<anixart::Release::Category> category) {
    anixart::requests::FilterRequest request;
    if (status == anixart::Release::Status::Ongoing) {
        request.episodes_count_from = 1;
        request.episodes_count_to = 48;
    }
    request.status = status;
    request.category = category;
    request.sort = anixart::requests::FilterRequest::Sort::Popular;
    return api->search().filter_search(request, false, 0);
}

@interface ReleasesPopularPageViewController ()
@property(nonatomic, strong) LibanixartApi* api_proxy;

@end

@implementation ReleasesPopularPageViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"app.discover.popular", "");
    
    [self setPageViewControllers:@[
        [[ReleasesViewController alloc] initWithPages:make_popular_pages(_api_proxy.api, anixart::Release::Status::Ongoing, std::nullopt)],
        [[ReleasesViewController alloc] initWithPages:make_popular_pages(_api_proxy.api, anixart::Release::Status::Finished, std::nullopt)],
        [[ReleasesViewController alloc] initWithPages:make_popular_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Movies)],
        [[ReleasesViewController alloc] initWithPages:make_popular_pages(_api_proxy.api, std::nullopt, anixart::Release::Category::Ova)]
    ]];
    	
    [self setSegmentTitles:@[
        NSLocalizedString(@"app.pages.releases.ongoing", ""),
        NSLocalizedString(@"app.pages.releases.finished", ""),
        NSLocalizedString(@"app.pages.releases.movies", ""),
        NSLocalizedString(@"app.pages.releases.ova", "")
    ]];
}

@end

