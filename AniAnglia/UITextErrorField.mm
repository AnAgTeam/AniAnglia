//
//  UITextErrorField.m
//  iOSAnixart
//
//  Created by Toilettrauma on 21.08.2024.
//

#import <Foundation/Foundation.h>
#import "UITextErrorField.h"

@implementation UITextErrorField
-(instancetype)init {
    self = [super init];
    
    
    _field = [UITextField new];
    _label = [UILabel new];
    [self addSubview:_field];
    [self addSubview:_label];
    
    _field.translatesAutoresizingMaskIntoConstraints = NO;
    [_field.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_field.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-20].active = YES;
    [_field.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_field.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [_label.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_label.heightAnchor constraintEqualToConstant:20.0].active = YES;
    [_label.topAnchor constraintEqualToAnchor:_field.bottomAnchor].active = YES;
    [_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:7.0].active = YES;
    _label.textColor = [UIColor redColor];
    
    return self;
}
-(void)showError:(NSString*)message {
    _field.layer.borderColor = [UIColor redColor].CGColor;
    _label.text = message;
}
-(void)clearError {
    _field.layer.borderColor = [UIColor clearColor].CGColor;
    _label.text = @"";
}
@end
