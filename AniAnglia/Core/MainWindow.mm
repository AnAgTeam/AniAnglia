//
//  MainWindow.m
//  AniAnglia
//
//  Created by Toilettrauma on 05.04.2025.
//

#import <Foundation/Foundation.h>
#import "MainWindow.h"
#import "AppDataController.h"
#import "AuthViewController.h"
#import "MainTabBarController.h"

@interface MainWindow ()
@end

@implementation MainWindow

-(instancetype)initWithWindowScene:(UIWindowScene*)scene {
    self = [super initWithWindowScene:scene];
    
    [self setRootViewController:[self getFirstRootViewController]];
    
    return self;
}
-(UIViewController*)getFirstRootViewController {
    NSString* token = [[AppDataController sharedInstance] getToken];
    if ([token length] == 0) {
        return [[UINavigationController alloc] initWithRootViewController:[AuthViewController new]];
    }
    return [MainTabBarController new];
}

-(void)setRootViewController:(UIViewController*)root_view_controller {
    root_view_controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [super setRootViewController: root_view_controller];
}

@end
