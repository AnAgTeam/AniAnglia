//
//  UITextErrorField.h
//  iOSAnixart
//
//  Created by Toilettrauma on 21.08.2024.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextErrorField : UIView
@property(nonatomic, retain) UITextField* field;
@property(nonatomic, retain) UILabel* label;
-(instancetype)init;
-(void)showError:(NSString*)message;
-(void)clearError;
@end
