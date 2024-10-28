//
//  AuthChecker.h
//  iOSAnixart
//
//  Created by Toilettrauma on 23.08.2024.
//

enum class AuthCheckerStatus {
    Normal = 0,
    TooShort,
    TooLong,
    Invalid
};

@interface AuthChecker : NSObject

-(instancetype)init;
-(AuthCheckerStatus)checkUsername:(NSString*)username;
-(AuthCheckerStatus)checkEmail:(NSString*)email;
-(AuthCheckerStatus)checkPassword:(NSString*)password;
@end
