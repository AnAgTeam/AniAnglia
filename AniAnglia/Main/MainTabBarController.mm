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
#import "NavSearchViewController.h"

@interface MainTabBarController ()
@end

@implementation MainTabBarController

-(instancetype)init {
    self = [super init];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(UINavigationController*)tabWithViewController:(NavigationSearchViewController<NavigationSearchDelegate>*)view_controller filterEnabled:(BOOL)filter_enabled historyEnabled:(BOOL)history_enabled title:(NSString*)local_title image:(NSString*)image_sys_name searchBarPlaceholder:(NSString*)local_search_ph{
    view_controller.search_delegate = view_controller;
    view_controller.filter_enabled = filter_enabled;
    // view_controller.history_enabled = history_enabled;
    UINavigationController* nav_controller = [[UINavigationController alloc] initWithRootViewController:view_controller];
    nav_controller.tabBarItem.title = NSLocalizedString(local_title, "");
    nav_controller.tabBarItem.image = [UIImage systemImageNamed:image_sys_name];
    nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:[NSString stringWithFormat:@"%@.fill", image_sys_name]];
    view_controller.search_bar.placeholder = NSLocalizedString(local_search_ph, "");
    return nav_controller;
}

-(void)setupView {
    [self setupTabs];
    [self setupLayout];
}

-(void)setupTabs {
    _main_nav_controller = [self tabWithViewController:[MainViewController new] filterEnabled:YES historyEnabled:YES title:@"app.main_tab_bar.main_tab.title" image:@"house" searchBarPlaceholder:@"app.main.search_bar.placeholder"];
    _discover_nav_controller = [self tabWithViewController:[DiscoverViewController new] filterEnabled:YES historyEnabled:YES title:@"app.main_tab_bar.discover_tab.title" image:@"safari" searchBarPlaceholder:@"app.discover.search_bar.placeholder"];
    _bookmarks_nav_controller = [self tabWithViewController:[MainViewController new] filterEnabled:NO historyEnabled:NO title:@"app.main_tab_bar.bookmarks_tab.title" image:@"bookmark" searchBarPlaceholder:@"app.bookmarks.search_bar.placeholder"];
    UIStoryboard* profile_storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
    ProfileViewController* profile_view_controller = [profile_storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    _profile_nav_controller = [self tabWithViewController:profile_view_controller filterEnabled:NO historyEnabled:NO title:@"app.main_tab_bar.profile_tab.title" image:@"person" searchBarPlaceholder:@"app.profile.search_bar.placeholder"];
    
    [self setViewControllers:@[
            _main_nav_controller,
            _discover_nav_controller,
            _bookmarks_nav_controller,
            _profile_nav_controller
        ]
    ];
}

-(void)setupLayout {
    self.tabBar.unselectedItemTintColor = [AppColorProvider textSecondaryColor];
    self.tabBar.tintColor = [AppColorProvider primaryColor];
    self.tabBar.backgroundColor = [AppColorProvider backgroundColor];
}

@end
