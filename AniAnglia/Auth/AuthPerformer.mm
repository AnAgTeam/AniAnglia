//
//  AuthPerformer.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.11.2025.
//

#import <Foundation/Foundation.h>
#import "AuthPerformer.h"
#import "AppDataController.h"
#import "StringCvt.h"
#import "MainWindow.h"
#import "AuthViewController.h"
#import "MainTabBarController.h"

@interface AuthPerformer ()

@end

@implementation AuthPerformer

+(void)performAuthWithProfile:(anixart::Profile::Ptr)profile profileToken:(anixart::ProfileToken)profile_token {
    AppDataController* data_controller = [AppDataController sharedInstance];
    [data_controller setToken:TO_NSSTRING(profile_token.token)];
    [data_controller setMyProfileID:profile->id];
    [LibanixartApi sharedInstance].api->set_token(profile_token.token);
    
    MainWindow* main_window = (MainWindow*)[[[UIApplication sharedApplication] delegate] window];
    [main_window setRootViewController:[MainTabBarController new]];
}

+(void)performLogout {
    AppDataController* data_controller = [AppDataController sharedInstance];
    // TODO: don't set token and instead set is_logged_in
    [data_controller setToken:@""];
    [data_controller setMyProfileID:static_cast<anixart::ProfileID>(0)];
    
    MainWindow* main_window = (MainWindow*)[[[UIApplication sharedApplication] delegate] window];
    UINavigationController* nav_controller = [[UINavigationController alloc] initWithRootViewController:[AuthViewController new]];
    [main_window setRootViewController:nav_controller];
}

@end
