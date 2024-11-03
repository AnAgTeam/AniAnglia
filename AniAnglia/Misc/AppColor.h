//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AppColorTheme
-(UIColor*)backgroundColor;
-(UIColor*)foregroundColor1;
-(UIColor*)foregroundColor2;
-(UIColor*)primaryColor;
-(UIColor*)secondaryColor;
-(UIColor*)alertColor;
-(UIColor*)successColor;
-(UIColor*)idleColor;
-(UIColor*)textColor;
-(UIColor*)textSecondaryColor;
-(UIColor*)textShyColor;
@end

@interface AppDefaultDarkTheme : NSObject <AppColorTheme>
-(UIColor*)backgroundColor;
-(UIColor*)foregroundColor1;
-(UIColor*)foregroundColor2;
-(UIColor*)primaryColor;
-(UIColor*)secondaryColor;
-(UIColor*)alertColor;
-(UIColor*)successColor;
-(UIColor*)idleColor;
-(UIColor*)textColor;
-(UIColor*)textSecondaryColor;
-(UIColor*)textShyColor;
@end

@interface AppDefaultLightTheme : NSObject <AppColorTheme>
-(UIColor*)backgroundColor;
-(UIColor*)foregroundColor1;
-(UIColor*)foregroundColor2;
-(UIColor*)primaryColor;
-(UIColor*)secondaryColor;
-(UIColor*)alertColor;
-(UIColor*)successColor;
-(UIColor*)idleColor;
-(UIColor*)textColor;
-(UIColor*)textSecondaryColor;
-(UIColor*)textShyColor;
@end

typedef UIColor*(^app_theme_color_getter_t)(id<AppColorTheme>);

@interface AppColorProvider : NSObject
+(id<AppColorTheme>)getThemeForStyle:(UIUserInterfaceStyle)style;
+(void)setTheme:(id<AppColorTheme>)theme forStyle:(UIUserInterfaceStyle)style;
+(UIColor*)colorFromThemeDynamic:(app_theme_color_getter_t)getter;

+(UIColor*)backgroundColor;
+(UIColor*)foregroundColor1;
+(UIColor*)foregroundColor2;
+(UIColor*)primaryColor;
+(UIColor*)secondaryColor;

+(UIColor*)alertColor;
+(UIColor*)successColor;
+(UIColor*)idleColor;

+(UIColor*)textColor;
+(UIColor*)textSecondaryColor;
+(UIColor*)textShyColor;
@end
