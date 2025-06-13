//
//  StringCvt.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import <string>

inline NSString* TO_NSSTRING(std::string& str) {
    return [NSString stringWithCString:str.c_str() encoding:NSUTF8StringEncoding];
}
inline std::string TO_STDSTRING(NSString* str) {
    return std::string([str UTF8String], [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
}

/*
 https://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
*/
@interface AbbreviateNumberFormatter : NSNumberFormatter
+(NSString*)stringFromNumber:(long long)num;
@end

@interface HTMLStyleFormatter : NSFormatter
+(NSString*)stringFromString:(NSString*)string;
@end
