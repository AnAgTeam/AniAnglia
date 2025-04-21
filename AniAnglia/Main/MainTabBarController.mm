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
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "AppDataController.h"
#import "FilterViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "ReleasesViewController.h"
#import "ProfilesTableViewController.h"

@interface ReleasesSearchController : UIViewController <SearchViewControllerDataSource, SearchViewControllerDelegate, ReleasesHistoryTableViewControllerDelegate>
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) SearchViewController* search_view_controller;
@property(nonatomic, retain) ReleasesViewController* view_controller;

-(instancetype)initWithQuery:(NSString*)query;

-(void)setQuery:(NSString*)query;
@end

@interface ProfilesSearchController : NSObject <SearchViewControllerDataSource, SearchViewControllerDelegate>
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) SearchViewController* search_view_controller;
@property(nonatomic, retain) ProfilesTableViewController* view_controller;

-(instancetype)initWithQuery:(NSString*)query;

-(void)setQuery:(NSString*)query;
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

@property(nonatomic, retain) ReleasesSearchController* main_releases_search_controller;
@property(nonatomic, retain) ReleasesSearchController* discover_releases_search_controller;
@property(nonatomic, retain) ProfilesSearchController* profiles_search_controller;
@end

@implementation ReleasesSearchController

-(instancetype)initWithQuery:(NSString*)query {
    self = [super init];
    
    _app_data_controller = [AppDataController sharedInstance];
    _api_proxy = [LibanixartApi sharedInstance];
    [self setQuery:query];
    
    return self;
}

-(void)setQuery:(NSString *)query {
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);
    anixart::ReleaseSearchPages::UPtr pages = _api_proxy.api->search().release_search(request, 0);
    
    _view_controller = [[ReleasesViewController alloc] initWithPages:std::move(pages)];
    
    _search_view_controller = [[SearchViewController alloc] initWithContentViewController:_view_controller];
    _search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.release.search.placeholder", "");
    [_search_view_controller setSearchText:query];
    _search_view_controller.data_source = self;
    _search_view_controller.delegate = self;
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
        
    [_view_controller setPages:std::move(pages)];
}
-(void)releasesHistoryTableViewController:(ReleasesHistoryTableViewController*)history_table_view_controller didSelectHistoryItem:(NSString*)item_name {
    [_search_view_controller setSearchText:item_name];
    [_search_view_controller endSearching];
    
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(item_name);
    anixart::ReleaseSearchPages::UPtr pages = _api_proxy.api->search().release_search(request, 0);
    
    [_view_controller setPages:std::move(pages)];
}

@end

@implementation ProfilesSearchController

-(instancetype)initWithQuery:(NSString*)query {
    self = [super init];
    
    _app_data_controller = [AppDataController sharedInstance];
    _api_proxy = [LibanixartApi sharedInstance];
    [self setQuery:query];
    
    return self;
}

-(void)setQuery:(NSString *)query {
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);
    anixart::ProfileSearchPages::UPtr pages = _api_proxy.api->search().profile_search(request, 0);
    
    _view_controller = [[ProfilesTableViewController alloc] initWithTableView:[UITableView new] pages:std::move(pages)];
    
    _search_view_controller = [[SearchViewController alloc] initWithContentViewController:_view_controller];
    _search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.profile.search.placeholder", "");
    [_search_view_controller setSearchText:query];
    _search_view_controller.data_source = self;
    _search_view_controller.delegate = self;
}

-(UIViewController*)inlineViewControllerForSearchViewController:(SearchViewController*)search_view_controller {
    return nil;
}
-(void)searchViewController:(SearchViewController*)search_view_controller didSearchWithQuery:(NSString*)query {
    [_app_data_controller addSearchHistoryItem:query];
    anixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);

    [_view_controller setPages:_api_proxy.api->search().profile_search(request, 0)];
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
    _main_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.release.search.placeholder", "");
    _main_search_view_controller.right_bar_button = _main_filter_bar_button;
    
    _discover_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[DiscoverViewController new]];
    _discover_search_view_controller.data_source = self;
    _discover_search_view_controller.delegate = self;
    _discover_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.release.search.placeholder", "");
    _discover_search_view_controller.right_bar_button = _discover_filter_bar_button;
    
    _bookmarks_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[BookmarksViewController new]];
    _bookmarks_search_view_controller.data_source = self;
    _bookmarks_search_view_controller.delegate = self;
    _bookmarks_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.bookmarks.search_bar.placeholder", "");
    
    _profile_search_view_controller = [[SearchViewController alloc] initWithContentViewController:[[ProfileViewController alloc] initWithMyProfile]];
    _profile_search_view_controller.data_source = self;
    _profile_search_view_controller.delegate = self;
    _profile_search_view_controller.search_bar_placeholder = NSLocalizedString(@"app.profile.search.placeholder", "");
    _profile_search_view_controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsBarButtonPressed:)];
    
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
    ]];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tabBar.unselectedItemTintColor = [UIColor systemGrayColor];
    self.tabBar.tintColor = [AppColorProvider primaryColor];
    self.tabBar.backgroundColor = [AppColorProvider backgroundColor];
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
    [search_view_controller setSearchText:@""];
    if (search_view_controller == _main_search_view_controller) {
        [_app_data_controller addSearchHistoryItem:query];
        
        // TODO: change
        if (!_main_releases_search_controller) {
            _main_releases_search_controller = [[ReleasesSearchController alloc] initWithQuery:query];
        } else {
            [_main_releases_search_controller setQuery:query];
        }
        [search_view_controller.navigationController pushViewController:_main_releases_search_controller.search_view_controller animated:YES];
        return;
    }
    if (search_view_controller == _discover_search_view_controller) {
        [_app_data_controller addSearchHistoryItem:query];
        
        if (!_discover_releases_search_controller) {
            _discover_releases_search_controller = [[ReleasesSearchController alloc] initWithQuery:query];
        } else {
            [_discover_releases_search_controller setQuery:query];
        }
        [search_view_controller.navigationController pushViewController:_discover_releases_search_controller.search_view_controller animated:YES];
        return;
    }
    if (search_view_controller == _bookmarks_search_view_controller) {
        return;
    }
    if (search_view_controller == _profile_search_view_controller) {
        if (!_profiles_search_controller) {
            _profiles_search_controller = [[ProfilesSearchController alloc] initWithQuery:query];
        } else {
            [_profiles_search_controller setQuery:query];
        }
        [search_view_controller.navigationController pushViewController:_profiles_search_controller.search_view_controller animated:YES];
        return;
    }
}
-(void)releasesHistoryTableViewController:(ReleasesHistoryTableViewController*)history_table_view_controller didSelectHistoryItem:(NSString*)item_name {
    [_current_history_responder_search_view_controller setSearchText:@""];
    [_current_history_responder_search_view_controller endSearching];
    
    if (_current_history_responder_search_view_controller == _main_search_view_controller) {
        // TODO: change
        if (!_main_releases_search_controller) {
            _main_releases_search_controller = [[ReleasesSearchController alloc] initWithQuery:item_name];
        } else {
            [_main_releases_search_controller setQuery:item_name];
        }
        [_current_history_responder_search_view_controller.navigationController pushViewController:_main_releases_search_controller.search_view_controller animated:YES];
        return;
    }
    if (_current_history_responder_search_view_controller == _discover_search_view_controller) {
        // TODO: change
        if (!_discover_releases_search_controller) {
            _discover_releases_search_controller = [[ReleasesSearchController alloc] initWithQuery:item_name];
        } else {
            [_discover_releases_search_controller setQuery:item_name];
        }
        [_current_history_responder_search_view_controller.navigationController pushViewController:_discover_releases_search_controller.search_view_controller animated:YES];
        return;
    }
}
-(void)onMainFilterBarButtonPressed {
    [_main_search_view_controller endSearching];
    [_main_nav_controller pushViewController:[FilterViewController new] animated:YES];
}
-(void)onDiscoverFilterBarButtonPressed {
    [_discover_search_view_controller endSearching];
    [_discover_nav_controller pushViewController:[FilterViewController new] animated:YES];
}
-(IBAction)onSettingsBarButtonPressed:(id)sender {
    UINavigationController* nav_controller = self.selectedViewController;
    [nav_controller pushViewController:[SettingsViewController new] animated:YES];
}

@end
