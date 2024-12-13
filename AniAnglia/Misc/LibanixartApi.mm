//
//  LibanixartApi.m
//  iOSAnixart
//
//  Created by Toilettrauma on 24.08.2024.
//

#import <Foundation/Foundation.h>
#import "LibanixartApi.h"
#import "AppDataController.h"
#import "StringCvt.h"

@interface LibanixartApi ()
@end

@implementation LibanixartApi

-(instancetype)init {
    self = [super init];
    
    _api = new libanixart::Api();
    _api->set_verbose(false, false);
    _api->set_token(TO_STDSTRING([[AppDataController sharedInstance] getToken]));
    _parsers = new libanixart::parsers::Parsers();
    
    return self;
}
-(void)dealloc {
    delete _api;
}

-(libanixart::Api*)getApi {
    return _api;
}
-(libanixart::parsers::Parsers*)getParsers {
    return _parsers;
}
-(void)performAsyncBlock:(BOOL(^)(libanixart::Api* api))block withUICompletion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            BOOL should_call_completion = block(self->_api);
            if (should_call_completion) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }
        }
        catch (libanixart::ApiError& e) {
            NSLog(@"Uncatched libanixart api exception: %s", e.what());
        }
        catch (libanixart::JsonError& e) {
            NSLog(@"Uncatched libanixart api json exception: %s", e.what());
        }
        catch (libanixart::UrlSessionError& e) {
            NSLog(@"Uncatched libanixart::UrlSession exception: %s", e.what());
        }
    });
}

+(instancetype)sharedInstance {
    static LibanixartApi* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [LibanixartApi new];
    });
    return sharedInstance;
}

@end
