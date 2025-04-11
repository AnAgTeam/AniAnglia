//
//  SharedRunningData.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.04.2025.
//

#import <Foundation/Foundation.h>
#import "SharedRunningData.h"
#import "AppDataController.h"

@interface SharedRunningData () {
    anixart::Profile::Ptr _my_profile;
}
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, strong) LibanixartApi* api_proxy;

@end

@implementation SharedRunningData

-(instancetype)init {
    self = [super init];
    
    _app_data_controller = [AppDataController sharedInstance];
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)asyncGetMyProfile:(void(^)(anixart::Profile::Ptr profile))completion_handler {
    if (_my_profile) {
        completion_handler(_my_profile);
    } else {
        [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
            auto [my_profile, is_my_profile] = api->profiles().get_profile([self->_app_data_controller getMyProfileID]);
            self->_my_profile = my_profile;
            return YES;
        } withUICompletion:^{
            completion_handler(self->_my_profile);
        }];
    }
}

+(instancetype)sharedInstance {
    static SharedRunningData* shared_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        shared_instance = [SharedRunningData new];
    });
    return shared_instance;
}

@end
