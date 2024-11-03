//
//  LibanixartApi.h
//  iOSAnixart
//
//  Created by Toilettrauma on 24.08.2024.
//

#import <Foundation/Foundation.h>
#import <libanixart/Api.hpp>
#import <libanixart/Parsers.hpp>

@interface LibanixartApi : NSObject {
    libanixart::Api* _api;
}
@property(nonatomic, getter = getApi) libanixart::Api* api;
@property(nonatomic, getter = getParsers) libanixart::parsers::Parsers* parsers;

-(instancetype)init;
-(void)dealloc;
-(libanixart::Api*)getApi;
-(libanixart::parsers::Parsers*)getParsers;
+ (instancetype)sharedInstance;
@end
