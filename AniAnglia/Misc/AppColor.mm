//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppUIColor.h"

@implementation AppDefaultColorScheme

-(UIColor*)darkColor1 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.1, 0.1, 0.1, 1.0)];
}
-(UIColor*)darkColor2 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.15, 0.15, 0.15, 1.0)];
}
-(UIColor*)darkColor3 {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.22, 0.22, 0.22, 1.0)];
}
-(UIColor*)darkPrimaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.126, 0.294, 0.757, 1.0)];
}
-(UIColor*)darkSecondaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.757, 0.126, 0.126, 1.0)];
}
-(UIColor*)darkTextColor {
    return [UIColor whiteColor];
}
-(UIColor*)lightColor1 {
    return [UIColor whiteColor];
}
-(UIColor*)lightColor2 {
    return [UIColor whiteColor];
}
-(UIColor*)lightColor3 {
    return [UIColor whiteColor];
}
-(UIColor*)lightPrimaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.126, 0.294, 0.757, 1.0)];
}
-(UIColor*)lightSecondaryColor {
    return [UIColor colorWithCGColor:CGColorCreateGenericRGB(0.757, 0.126, 0.126, 1.0)];
}
-(UIColor*)lightTextColor {
    return [UIColor blackColor];
}

@end

@implementation AppColorProvider
static UIUserInterfaceStyle default_style = UIUserInterfaceStyleDark;
static id<AppColorScheme> app_scheme = [AppDefaultColorScheme new];

typedef UIColor*(^color_getter_t)();
+(UIColor*) colorFromSchemeWithLightGetter:(color_getter_t)light_getter darkGetter: (color_getter_t)dark_getter {
    return [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait_collection) {
        UIUserInterfaceStyle style = trait_collection.userInterfaceStyle;
        if (style == UIUserInterfaceStyleUnspecified) {
            style = default_style;
        }
        if (style == UIUserInterfaceStyleDark) {
            return dark_getter();
        }
        return light_getter();
    }];
}

+(id<AppColorScheme>)getScheme {
    return app_scheme;
}
+(void)setScheme:(id<AppColorScheme>)scheme {
    app_scheme = scheme;
}

+(UIColor*)backColor1 {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightColor1];
    } darkGetter:^{
        return [app_scheme darkColor1];
    }];
}
+(UIColor*)backColor2 {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightColor2];
    } darkGetter:^{
        return [app_scheme darkColor2];
    }];
}
+(UIColor*)backColor3 {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightColor3];
    } darkGetter:^{
        return [app_scheme darkColor3];
    }];
}
+(UIColor*)primaryColor {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightPrimaryColor];
    } darkGetter:^{
        return [app_scheme darkPrimaryColor];
    }];
}
+(UIColor*)secondaryColor {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightSecondaryColor];
    } darkGetter:^{
        return [app_scheme darkSecondaryColor];
    }];
}
+(UIColor*)textColor {
    return [AppColorProvider colorFromSchemeWithLightGetter:^{
        return [app_scheme lightTextColor];
    } darkGetter:^{
        return [app_scheme darkTextColor];
    }];
}

@end
