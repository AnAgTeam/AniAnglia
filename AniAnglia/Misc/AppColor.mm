//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppColor.h"

@implementation AppDefaultDarkTheme
-(UIColor*)backgroundColor {
    return [UIColor systemBackgroundColor];
}
-(UIColor*)foregroundColor1 {
    return [UIColor secondarySystemBackgroundColor];
}
-(UIColor*)foregroundColor2 {
    return [UIColor tertiarySystemBackgroundColor];
}
-(UIColor*)primaryColor {
    return [UIColor systemBlueColor];
}
-(UIColor*)secondaryColor {
    return [UIColor systemRedColor];
}
-(UIColor*)alertColor {
    return [UIColor systemRedColor];
}
-(UIColor*)successColor {
    return [UIColor systemGreenColor];
}
-(UIColor*)idleColor {
    return [UIColor systemOrangeColor];
}
-(UIColor*)textColor {
    return [UIColor whiteColor];
}
-(UIColor*)textSecondaryColor {
    return [UIColor lightGrayColor];
}
-(UIColor*)textShyColor {
    return [UIColor grayColor];
}
@end

@implementation AppDefaultLightTheme
-(UIColor*)backgroundColor {
    return [UIColor systemBackgroundColor];
}
-(UIColor*)foregroundColor1 {
    return [UIColor secondarySystemBackgroundColor];
}
-(UIColor*)foregroundColor2 {
    return [UIColor tertiarySystemBackgroundColor];
}
-(UIColor*)primaryColor {
    return [UIColor systemBlueColor];
}
-(UIColor*)secondaryColor {
    return [UIColor systemRedColor];
}
-(UIColor*)alertColor {
    return [UIColor systemRedColor];
}
-(UIColor*)successColor {
    return [UIColor systemGreenColor];
}
-(UIColor*)idleColor {
    return [UIColor systemOrangeColor];
}
-(UIColor*)textColor {
    return [UIColor blackColor];
}
-(UIColor*)textSecondaryColor {
    return [UIColor darkGrayColor];
}
-(UIColor*)textShyColor {
    return [UIColor grayColor];
}
@end

struct AppThemes {
    id<AppColorTheme> light;
    id<AppColorTheme> dark;
};
@implementation AppColorProvider
static UIUserInterfaceStyle default_style = UIUserInterfaceStyleDark;
static AppThemes app_themes = {
    .light = [AppDefaultLightTheme new],
    .dark = [AppDefaultDarkTheme new]
};

+(id<AppColorTheme>)getThemeForStyle:(UIUserInterfaceStyle)style {
    auto getTheme = [](const UIUserInterfaceStyle style) -> id<AppColorTheme> {
        switch (style) {
            case UIUserInterfaceStyleLight:
                return app_themes.light;
            case UIUserInterfaceStyleDark:
                return app_themes.dark;
            default:
                return nil;
        }
    };
    id<AppColorTheme> theme = getTheme(style);
    if (!theme) {
        // Unspecified
        theme = getTheme(default_style);
    }
    return theme;
}
+(void)setTheme:(id<AppColorTheme>)theme forStyle:(UIUserInterfaceStyle)style {
    switch (style) {
        case UIUserInterfaceStyleLight:
            app_themes.light = theme;
            return;
        case UIUserInterfaceStyleDark:
            app_themes.dark = theme;
            return;
        default:
            return;
    }
}
+(UIColor*)colorFromThemeDynamic:(app_theme_color_getter_t)getter {
    return [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait_collection) {
        id<AppColorTheme> theme = [self getThemeForStyle:trait_collection.userInterfaceStyle];
        return getter(theme);
    }];
}

+(UIColor*)backgroundColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme backgroundColor];
    }];
}
+(UIColor*)foregroundColor1 {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme foregroundColor1];
    }];
}
+(UIColor*)foregroundColor2 {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme foregroundColor2];
    }];
}
+(UIColor*)primaryColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme primaryColor];
    }];
}
+(UIColor*)secondaryColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme secondaryColor];
    }];
}
+(UIColor*)alertColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme alertColor];
    }];
}
+(UIColor*)successColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme successColor];
    }];
}
+(UIColor*)idleColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme idleColor];
    }];
}
+(UIColor*)textColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme textColor];
    }];
}
+(UIColor*)textSecondaryColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme textSecondaryColor];
    }];
}
+(UIColor*)textShyColor {
    return [AppColorProvider colorFromThemeDynamic:^UIColor*(id<AppColorTheme> theme){
        return [theme textShyColor];
    }];
}
@end
