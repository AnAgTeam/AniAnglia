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
        @"search_history": @[],
        @"token": @""
    }];
    
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
    return [_user_defaults stringForKey:@"token"];
}
-(void)writeToken:(NSString*)token {
    [_user_defaults setObject:token forKey:@"token"];
}
-(NSArray<NSString*>*)getSearchHistory {
    return [_user_defaults arrayForKey:@"search_history"];
}
-(void)addSearchHistoryItem:(NSString*)item {
    if ([item length] == 0) {
        NSLog(@"WARNING: empty history item! (addSearchHistoryItem:)");
        return;
    }
    NSMutableArray<NSString*>* history = [[_user_defaults arrayForKey:@"search_history"] mutableCopy];
    for (NSString* history_item in history) {
        if ([history_item isEqual:item]) {
            [history removeObject:history_item];
            break;
        }
    }
    [history insertObject:item atIndex:0];
    [_user_defaults setObject:history forKey:@"search_history"];
}
-(NSUInteger)getSearchHistoryLength {
    return [[self getSearchHistory] count];
}
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index {
    return [[self getSearchHistory] objectAtIndex:index];
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
