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
/* completion executed if block returned TRUE, if returned FALSE or libanixart error catched it isn't executed */
-(void)performAsyncBlock:(BOOL(^)(libanixart::Api* api))block withUICompletion:(void(^)())completion;

+(instancetype)sharedInstance;
@end
