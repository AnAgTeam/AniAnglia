//
//  LibanixartApi.h
//  iOSAnixart
//
//  Created by Toilettrauma on 24.08.2024.
//

#import <Foundation/Foundation.h>
#import <anixart/Api.hpp>
#import <anixart/Parsers.hpp>

@interface LibanixartApi : NSObject {
    anixart::Api* _api;
}
@property(nonatomic, getter = getApi) anixart::Api* api;
@property(nonatomic, getter = getParsers) anixart::parsers::Parsers* parsers;

-(instancetype)init;
-(void)dealloc;
-(anixart::Api*)getApi;
-(anixart::parsers::Parsers*)getParsers;
/* completion executed if block returned TRUE, if returned FALSE or libanixart error catched it isn't executed */
-(void)performAsyncBlock:(BOOL(^)(anixart::Api* api))block withUICompletion:(void(^)())completion;

-(NSArray<NSString*>*)getGenresArray;
-(NSArray<NSString*>*)getStudiosArray;

+(instancetype)sharedInstance;
@end
