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
#import "NavigationAndSearchController.h"

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
    _main_nav_controller = [[NavigationSearchController alloc] initWithDelegateRootViewController:[MainViewController new] filterEnabled:YES];
    _discover_nav_controller = [[NavigationSearchController alloc] initWithDelegateRootViewController:[DiscoverViewController new] filterEnabled:YES];
    _bookmarks_nav_controller = [[NavigationSearchController alloc] initWithDelegateRootViewController:[BookmarksViewController new] filterEnabled:YES];
//    UIStoryboard *profile_storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
//    UIViewController *profile_view_controller = [profile_storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    _profile_nav_controller = [[NavigationSearchController alloc] initWithDelegateRootViewController:[ProfileViewController new] filterEnabled:NO];
    
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
