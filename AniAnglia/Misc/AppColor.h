//
//  AppUIColor.m
//  iOSAnixart
//
//  Created by Toilettrauma on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AppColorScheme
-(UIColor*)darkColor1;
-(UIColor*)darkColor2;
-(UIColor*)darkColor3;
-(UIColor*)darkPrimaryColor;
-(UIColor*)darkSecondaryColor;
-(UIColor*)darkTextColor;
-(UIColor*)lightColor1;
-(UIColor*)lightColor2;
-(UIColor*)lightColor3;
-(UIColor*)lightPrimaryColor;
-(UIColor*)lightSecondaryColor;
-(UIColor*)lightTextColor;
@end

@interface AppDefaultColorScheme : NSObject <AppColorScheme>
-(UIColor*)darkColor1;
-(UIColor*)darkColor2;
-(UIColor*)darkColor3;
-(UIColor*)darkPrimaryColor;
-(UIColor*)darkSecondaryColor;
-(UIColor*)lightColor1;
-(UIColor*)lightColor2;
-(UIColor*)lightColor3;
-(UIColor*)lightPrimaryColor;
-(UIColor*)lightSecondaryColor;
@end

@interface AppColorProvider : NSObject

+(id<AppColorScheme>)getScheme;
+(void)setScheme:(id<AppColorScheme>)scheme;

+(UIColor*)backColor1;
+(UIColor*)backColor2;
+(UIColor*)backColor3;
+(UIColor*)primaryColor;
+(UIColor*)secondaryColor;
+(UIColor*)textColor;

@end
