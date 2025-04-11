//
//  SharedRunningData.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.04.2025.
//

#ifndef SharedRunningData_h
#define SharedRunningData_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface SharedRunningData : NSObject

-(void)asyncGetMyProfile:(void(^)(anixart::Profile::Ptr profile))completion_handler;

+(instancetype)sharedInstance;
@end


#endif /* SharedRunningData_h */
