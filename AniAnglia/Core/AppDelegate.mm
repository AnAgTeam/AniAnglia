//
//  AppDelegate.m
//  iOSAnixart
//
//  Created by Toilettrauma on 16.08.2024.
//

#import "AppDelegate.h"
#import "AppDataController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    libanixart::api_init("ru");
    // setup audio
    AVAudioSession* audio_sess = [AVAudioSession sharedInstance];
    [audio_sess setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audio_sess setActive:NO error:nil];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
