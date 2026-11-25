//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import "AppColor.h"


#pragma mark - Акцентный цвет (по умолчанию оранжевый)

static NSString* const kAccentColorKey = @"anilot_accent_color";

static UIColor* DefaultAccentColor(void) {
    return [UIColor colorWithRed:242/255. green:139/255. blue:48/255. alpha:1];
}

static UIColor* CurrentAccentColor(void) {
    NSArray<NSNumber*>* components = [[NSUserDefaults standardUserDefaults] arrayForKey:kAccentColorKey];
    if (components.count == 3) {
        return [UIColor colorWithRed:components[0].doubleValue green:components[1].doubleValue blue:components[2].doubleValue alpha:1];
    }
    return DefaultAccentColor();
}

@implementation AppDefaultDarkTheme
-(UIColor*)backgroundColor {
    return [UIColor blackColor];
}
-(UIColor*)foregroundColor1 {
    // почти чёрный с лёгким тёплым оттенком акцента, без серого
    return [UIColor colorWithRed:12/255. green:9/255. blue:6/255. alpha:1];
}
-(UIColor*)foregroundColor2 {
    return [UIColor colorWithRed:22/255. green:16/255. blue:10/255. alpha:1];
}
-(UIColor*)primaryColor {
    return CurrentAccentColor();
}
-(UIColor*)secondaryColor {
    return [UIColor systemRedColor];
}
-(UIColor*)alertColor {
    return [UIColor systemRedColor];
}
-(UIColor*)successColor {
    return [UIColor colorWithRed:76/255. green:175/255. blue:80/255. alpha:1];
}
-(UIColor*)idleColor {
    return CurrentAccentColor();
}
-(UIColor*)textColor {
    return [UIColor whiteColor];
}
-(UIColor*)textSecondaryColor {
    return [CurrentAccentColor() colorWithAlphaComponent:0.8];
}
-(UIColor*)textShyColor {
    return [CurrentAccentColor() colorWithAlphaComponent:0.55];
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
    return CurrentAccentColor();
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

+(UIColor*)accentColor {
    return CurrentAccentColor();
}
+(UIColor*)defaultAccentColor {
    return DefaultAccentColor();
}
+(void)setAccentColor:(UIColor*)color {
    if (color) {
        CGFloat r = 0, g = 0, b = 0, a = 0;
        [color getRed:&r green:&g blue:&b alpha:&a];
        [[NSUserDefaults standardUserDefaults] setObject:@[@(r), @(g), @(b)] forKey:kAccentColorKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccentColorKey];
    }
    [self refreshAllWindows];
}
+(void)refreshAllWindows {
    // динамические цвета пересчитываются при смене traitCollection: кратко переключаем стиль окна
    for (UIScene* scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        for (UIWindow* window in ((UIWindowScene*)scene).windows) {
            UIUserInterfaceStyle original = window.overrideUserInterfaceStyle;
            window.overrideUserInterfaceStyle = (window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? UIUserInterfaceStyleLight : UIUserInterfaceStyleDark;
            dispatch_async(dispatch_get_main_queue(), ^{
                window.overrideUserInterfaceStyle = original;
            });
        }
    }
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
