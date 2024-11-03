//
//  ApiDataController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppDataController.h"
#import "LibanixartApi.h"

@interface AppDataController ()
@property(nonatomic, retain) NSUserDefaults* user_defaults;
@end

@implementation AppDataController

-(instancetype)init {
    self = [super init];
    
    _user_defaults = [NSUserDefaults standardUserDefaults];
    [_user_defaults registerDefaults:@{
        @"token": @""
    }];
    [self readToken];
    
    return self;
}

-(NSString*)getToken {
    return _token;
}
-(void)setToken:(NSString*)token {
    _token = token;
    [self writeToken:token];
}
-(NSString*)readToken {
    return [_user_defaults objectForKey:@"token"];
}
-(void)writeToken:(NSString*)token {
    [_user_defaults setObject:token forKey:@"token"];
}

+(instancetype)sharedInstance {
    static AppDataController* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AppDataController new];
    });
    return sharedInstance;
}

@end
