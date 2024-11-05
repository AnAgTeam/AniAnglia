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

-(void)setupView {
    UIViewController* main_view_controller = [[NavigationSearchViewController alloc] initWithDelegate:[MainViewController new] filterEnabled:YES];
    _main_nav_controller = [[UINavigationController alloc] initWithRootViewController:main_view_controller];
    UIViewController* discover_view_controller = [[NavigationSearchViewController alloc] initWithDelegate:[DiscoverViewController new] filterEnabled:YES];
    _discover_nav_controller = [[UINavigationController alloc] initWithRootViewController:discover_view_controller];
    UIViewController* bookmarks_view_controller = [[NavigationSearchViewController alloc] initWithDelegate:[BookmarksViewController new] filterEnabled:YES];
    _bookmarks_nav_controller = [[UINavigationController alloc] initWithRootViewController:bookmarks_view_controller];
    UIStoryboard* profile_storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
    ProfileViewController* profile_view_controller = [profile_storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profile_view_controller.search_delegate = profile_view_controller;
    _profile_nav_controller = [[UINavigationController alloc] initWithRootViewController:profile_view_controller];
    
    [self setupTabs];
    [self setupLayout];
}

-(void)setupTabs {
    _main_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.main_tab.title", "");
    _main_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"house"];
    _main_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"house.fill"];
    _discover_nav_controller.tabBarItem.title = NSLocalizedString(@"app.main_tab_bar.discover_tab.title", "");
    _discover_nav_controller.tabBarItem.image = [UIImage systemImageNamed:@"safari"];
    _discover_nav_controller.tabBarItem.selectedImage = [UIImage systemImageNamed:@"safari.fill"];
    _bookmarks_nav_controller.title = NSLocalizedString(@"app.main_tab_bar.bookmarks_tab.title", "");
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
    self.tabBar.unselectedItemTintColor = [AppColorProvider textSecondaryColor];
    self.tabBar.tintColor = [AppColorProvider primaryColor];
    self.tabBar.backgroundColor = [AppColorProvider backgroundColor];
}

@end
