//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppUIColor.h"

@implementation AppUIColor

+(UIColor*)darkColor1 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.1, 0.1, 0.1, 1.0)];
}
+(UIColor*)darkColor2 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.15, 0.15, 0.15, 1.0)];
}
+(UIColor*)darkColor3 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.22, 0.22, 0.22, 1.0)];
}
+(UIColor*)lightColor1 {
    return [UIColor whiteColor];
}
+(UIColor*)lightColor2 {
    return [UIColor whiteColor];
}
+(UIColor*)lightColor3 {
    return [UIColor whiteColor];
}
+(UIColor*)primaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.126, 0.294, 0.757, 1.0)];
}
+(UIColor*)secondaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.757, 0.126, 0.126, 1.0)];
}

@end
