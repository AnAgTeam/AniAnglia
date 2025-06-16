//
//  UITextErrorField.m
//  iOSAnixart
//
//  Created by Toilettrauma on 21.08.2024.
//

#import <Foundation/Foundation.h>
#import "TextErrorField.h"
#import "AppColor.h"

@implementation TextErrorField
-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _field = [UITextField new];
    _label = [UILabel new];
    
    [self addSubview:_field];
    [self addSubview:_label];
    
    _field.translatesAutoresizingMaskIntoConstraints = NO;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_field.widthAnchor constraintEqualToAnchor:self.widthAnchor],
        [_field.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-20],
        [_field.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_field.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        

        [_label.widthAnchor constraintEqualToAnchor:self.widthAnchor],
        [_label.heightAnchor constraintEqualToConstant:20.0],
        [_label.topAnchor constraintEqualToAnchor:_field.bottomAnchor],
        [_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:7.0]
    ]];
}
-(void)setupLayout {
    _label.textColor = [UIColor redColor];
}

// TODO: dynamic borderColor
-(void)showError:(NSString*)message {
    _field.layer.borderColor = [AppColorProvider alertColor].CGColor;
    _label.text = message;
}
-(void)clearError {
    _field.layer.borderColor = [UIColor clearColor].CGColor;
    _label.text = @"";
}
@end
