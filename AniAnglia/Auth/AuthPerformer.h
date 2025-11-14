//
//  AuthPerform.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.11.2025.
//

#ifndef AuthPerform_h
#define AuthPerform_h

#import <Foundation/Foundation.h>
#import "LibanixartApi.h"

@interface AuthPerformer : NSObject

+(void)performAuthWithProfile:(anixart::Profile::Ptr)profile profileToken:(anixart::ProfileToken)profile_token;

@end


#endif /* AuthPerform_h */
