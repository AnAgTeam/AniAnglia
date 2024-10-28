//
//  AuthChecker.m
//  iOSAnixart
//
//  Created by Toilettrauma on 23.08.2024.
//

#import <Foundation/Foundation.h>
#import "AuthChecker.h"

#define MAKE_STRING(x) @#x

@interface AuthChecker ()
@property(nonatomic, retain) NSRegularExpression* email_regex;
@property(nonatomic, retain) NSRegularExpression* password_regex;
@end

@implementation AuthChecker


-(instancetype)init {
    self = [super init];
    
    NSError* error = nil;
    _email_regex = [NSRegularExpression regularExpressionWithPattern:@"[^@]+@[^\\.]+(?:\\..+)?$" options:0 error:&error];
    _password_regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9 \\!\\\"\\#\\$\\%\\&\\'\\(\\)\\*\\+\\,-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\_\\`\\{\\|\\}\\~\\]]{6,32}$" options:0 error:&error];
    
    return self;
}

-(AuthCheckerStatus)checkUsername:(NSString*)username {
    if ([username length] > 20) {
        return AuthCheckerStatus::TooLong;
    }
    
    return AuthCheckerStatus::Normal;
}

-(AuthCheckerStatus)checkEmail:(NSString*)email {
    NSUInteger matches_count = [_email_regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if (matches_count == 0) {
        return AuthCheckerStatus::Invalid;
    }
    
    return AuthCheckerStatus::Normal;
}
-(AuthCheckerStatus)checkPassword:(NSString*)password {
    if ([password length] < 6) {
        return AuthCheckerStatus::TooShort;
    }
    if ([password length] > 32) {
        return AuthCheckerStatus::TooLong;
    }
    NSUInteger matches_count = [_password_regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])];
    if (matches_count == 0) {
        return AuthCheckerStatus::Invalid;
    }
    
    return AuthCheckerStatus::Normal;
}

@end
