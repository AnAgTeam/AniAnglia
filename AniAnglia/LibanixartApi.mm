//
//  LibanixartApi.m
//  iOSAnixart
//
//  Created by Toilettrauma on 24.08.2024.
//

#import <Foundation/Foundation.h>
#import "LibanixartApi.h"

@interface LibanixartApi ()
@end

@implementation LibanixartApi

-(instancetype)init {
    self = [super init];
    
    _api = new libanixart::Api();
    _api->set_verbose(false, false);
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

+ (instancetype)sharedInstance {
    static LibanixartApi* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [LibanixartApi new];
    });
    return sharedInstance;
}

@end
