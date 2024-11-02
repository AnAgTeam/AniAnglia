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
#import "AppUIColor.h"

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

-(void)setupView {
    _main_nav_controller = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    _discover_nav_controller = [[UINavigationController alloc] initWithRootViewController:[DiscoverViewController new]];
    _bookmarks_nav_controller = [[UINavigationController alloc] initWithRootViewController:[BookmarksViewController new]];
    _profile_nav_controller = [[UINavigationController alloc] initWithRootViewController:[ProfileViewController new]];
    [_main_nav_controller setToolbarHidden:YES];
    [_main_nav_controller setToolbarHidden:YES];
    [_bookmarks_nav_controller setToolbarHidden:YES];
    [_profile_nav_controller setToolbarHidden:YES];
    
    [self setupTabs];
    [self setupDarkLayout];
}

-(void)setupDarkLayout {
    self.tabBar.unselectedItemTintColor = [UIColor lightGrayColor];
    self.tabBar.tintColor = [AppUIColor primaryColor];
    self.tabBar.backgroundColor = [UIColor blackColor];
}

@end
