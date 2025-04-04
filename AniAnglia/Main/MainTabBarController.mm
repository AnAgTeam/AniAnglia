//
//  MainTabBarControllermm.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "MainTabBarController.h"
#import "MainViewController.h"
#import "DiscoverViewController.h"
#import "BookmarksViewController.h"
#import "ProfileViewController.h"
#import "AppColor.h"
#import "SearchViewController.h"
#import "ReleasesTableViewController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "AppDataController.h"
#import "FilterViewController.h"

@interface ReleasesSearchController : NSObject <SearchViewControllerDataSource, SearchViewControllerDelegate, ReleasesHistoryTableViewControllerDelegate>
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, weak) SearchViewController* search_view_controller;
@property(nonatomic, weak) ReleasesTableViewController* view_controller;
@end

@interface MainTabBarController ()
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, retain) SearchViewController* main_search_view_controller;
@property(nonatomic, retain) SearchViewController* discover_search_view_controller;
@property(nonatomic, retain) SearchViewController* bookmarks_search_view_controller;
@property(nonatomic, retain) SearchViewController* profile_search_view_controller;
@property(nonatomic, retain) UIBarButtonItem* main_filter_bar_button;
@property(nonatomic, retain) UIBarButtonItem* discover_filter_bar_button;
@property(nonatomic, weak) UINavigationController* current_history_responder_nav_controller;
@property(nonatomic, weak) SearchViewController* current_history_responder_search_view_controller;
@property(nonatomic, retain) ReleasesSearchController* releases_search_controller;
@end

@implementation ReleasesSearchController

-(instancetype)init {
    self = [super init];
    
    _app_data_controller = [AppDataController sharedInstance];
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(UIViewController*)inlineViewControllerForSearchViewController:(SearchViewController*)search_view_controller {
    ReleasesHistoryTableViewController* view_controller = [ReleasesHistoryTableViewController new];
    view_controller.delegate = self;
    return view_controller;
}
-(void)searchViewController:(SearchViewController*)search_view_controller didSearchWithQuery:(NSString*)query {
    [_app_data_controller addSearchHistoryItem:query];
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);
    anixart::ReleaseSearchPages::UPtr pages = _api_proxy.api->search().release_search(request, 0);
        
    [_view_controller updatePages:std::move(pages)];
}
-(void)releasesHistoryTableViewController:(ReleasesHistoryTableViewController*)history_table_view_controller didSelectHistoryItem:(NSString*)item_name {
    [_search_view_controller setSearchText:item_name];
    [_search_view_controller endSearching];
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(item_name);
    anixart::ReleaseSearchPages::UPtr pages = _api_proxy.api->search().release_search(request, 0);
    [_view_controller updatePages:std::move(pages)];
}

@end

@implementation MainTabBarController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupTabs];
    [self setupLayout];
}
-(void)setup {
    _main_filter_bar_button = [[UIBarButtonItem alloc] initWithPrimaryAction:[UIAction actionWithTitle:@"" image:[UIImage systemImageNamed:@"slider.horizontal.3"] identifier:nil handler:^(UIAction* action) {
        [self onMainFilterBarButtonPressed];
    }]];
    _discover_filter_bar_button = [[UIBarButtonItem alloc] initWithPrimaryAction:[UIAction actionWithTitle:@"" image:[UIImage systemImageNamed:@"slider.horizontal.3"] identifier:nil handler:^(UIAction* action) {
        [self onDiscoverFilterBarButtonPressed];
    }]];
}
-(void)setupTabs {
    _main_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[MainViewController new]];
    _main_search_view_controller.data_source = self;
    _main_search_view_controller.delegate = self;
    _main_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.main.search_bar.placeholder", "");
    _main_search_view_controller.right_bar_button = _main_filter_bar_button;
    _discover_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[DiscoverViewController new]];
    _discover_search_view_controller.data_source = self;
    _discover_search_view_controller.delegate = self;
    _discover_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.discover.search_bar.placeholder", "");
    _discover_search_view_controller.right_bar_button = _discover_filter_bar_button;
    _bookmarks_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[BookmarksViewController new]];
    _bookmarks_search_view_controller.data_source = self;
    _bookmarks_search_view_controller.delegate = self;
    _bookmarks_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.bookmarks.search_bar.placeholder", "");
    _profile_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[[ProfileViewController alloc] initWithMyProfile]];
    _profile_search_view_controller.data_source = self;
    _profile_search_view_controller.delegate = self;
    _profile_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.profile.search_bar.placeholder", "");
    
    _main_nav_controller = [[UINavigationController alloc] initWithRootViewController:_main_search_view_controller];
    _discover_nav_controller = [[UINavigationController alloc] initWithRootViewController:_discover_search_view_controller];
    _bookmarks_nav_controller = [[UINavigationController alloc] initWithRootViewController:_bookmarks_search_view_controller];
    _profile_nav_controller = [[UINavigationController alloc] initWithRootViewController:_profile_search_view_controller];
    
    _main_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.main_tab.title", "");
    _main_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"house"];
    _main_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"house.fill"];
    _discover_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.discover_tab.title", "");
    _discover_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"safari"];
    _discover_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"safari.fill"];
    _bookmarks_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.bookmarks_tab.title", "");
    _bookmarks_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"bookmark"];
    _bookmarks_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"bookmark.fill"];
    _profile_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.profile_tab.title", "");
    _profile_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"person"];
    _profile_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"person.fill"];

    [self setViewControllers:@[
            _main_nav_controller,
            _discover_nav_controller,
            _bookmarks_nav_controller,
            _profile_nav_controller
        ]
    ];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tabBar.unselectedItemTintColor = [UIColor systemGrayColor];
    self.tabBar.tintColor = [AppColorProvider primaryColor];
    self.tabBar.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)pushReleasesSearchViewControllerTo:(UINavigationController*)navigation_controller query:(NSString*)query placeholder:(NSString*)placeholder {
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);
    anixart::ReleaseSearchPages::UPtr pages = _api_proxy.api->search().release_search(request, 0);
    
    ReleasesTableViewController* releases_view_controller = [[ReleasesTableViewController alloc] initWithPages:std::move(pages)];
    SearchViewController* search_view_controller = [[SearchViewController alloc] initWithContentViewController:releases_view_controller];
    search_view_controller.search_bar_placeholder = placeholder;
    [search_view_controller setSearchText:query];
    
    _releases_search_controller = [ReleasesSearchController new];
    _releases_search_controller.search_view_controller = search_view_controller;
    _releases_search_controller.view_controller = releases_view_controller;
    search_view_controller.data_source = _releases_search_controller;
    search_view_controller.delegate = _releases_search_controller;
    
    [navigation_controller pushViewController:search_view_controller animated:YES];
}

-(UIViewController*)inlineViewControllerForSearchViewController:(SearchViewController*)search_view_controller {
    if (search_view_controller == _main_search_view_controller) {
        _current_history_responder_nav_controller = _main_nav_controller;
        _current_history_responder_search_view_controller = _main_search_view_controller;
        ReleasesHistoryTableViewController* view_controller = [ReleasesHistoryTableViewController new];
        view_controller.delegate = self;
        return view_controller;
    }
    if (search_view_controller == _discover_search_view_controller) {
        _current_history_responder_nav_controller = _discover_nav_controller;
        _current_history_responder_search_view_controller = _discover_search_view_controller;
        ReleasesHistoryTableViewController* view_controller = [ReleasesHistoryTableViewController new];
        view_controller.delegate = self;
        return view_controller;
    }
    if (search_view_controller == _bookmarks_search_view_controller) {
        return nil;
    }
    if (search_view_controller == _profile_search_view_controller) {
        return nil;
    }
    return nil;
}
-(void)searchViewController:(SearchViewController*)search_view_controller didSearchWithQuery:(NSString*)query {
    if (search_view_controller == _main_search_view_controller) {
        [_main_search_view_controller setSearchText:@""];
        [_app_data_controller addSearchHistoryItem:query];
        [self pushReleasesSearchViewControllerTo:_main_nav_controller query:query placeholder:_main_search_view_controller.search_bar_placeholder];
        return;
    }
    if (search_view_controller == _discover_search_view_controller) {
        [_discover_search_view_controller setSearchText:@""];
        [_app_data_controller addSearchHistoryItem:query];
        [self pushReleasesSearchViewControllerTo:_discover_nav_controller query:query placeholder:_discover_search_view_controller.search_bar_placeholder];
        return;
    }
    if (search_view_controller == _bookmarks_search_view_controller) {
        return;
    }
    if (search_view_controller == _profile_search_view_controller) {
        return;
    }
}
-(void)releasesHistoryTableViewController:(ReleasesHistoryTableViewController*)history_table_view_controller didSelectHistoryItem:(NSString*)item_name {
    [_current_history_responder_search_view_controller setSearchText:@""];
    [_current_history_responder_search_view_controller endSearching];
    [self pushReleasesSearchViewControllerTo:_current_history_responder_nav_controller query:item_name placeholder:_current_history_responder_search_view_controller.search_bar_placeholder];
}
-(void)onMainFilterBarButtonPressed {
    [_main_search_view_controller endSearching];
    [_main_nav_controller pushViewController:[FilterViewController new] animated:YES];
}
-(void)onDiscoverFilterBarButtonPressed {
    [_discover_search_view_controller endSearching];
    [_discover_nav_controller pushViewController:[FilterViewController new] animated:YES];
}

@end
