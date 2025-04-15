//
//  TextEnterView.m
//  AniAnglia
//
//  Created by Toilettrauma on 14.04.2025.
//

#import <Foundation/Foundation.h>
#import "TextEnterView.h"
#import "AppColor.h"

@interface TextEnterView () <UITextViewDelegate>
@property(nonatomic, retain) NSString* placeholder;
@property(nonatomic, retain) UIView* inner_view;
@property(nonatomic, retain) UITextView* text_view;
@property(nonatomic, retain) UIButton* spoiler_button;
@property(nonatomic, retain) UIButton* send_button;
@property(nonatomic, retain) UILabel* placeholder_label;
@property(nonatomic, retain) NSLayoutConstraint* text_view_height_constraint;

@end

@implementation TextEnterView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _inner_view = [UIView new];
    _inner_view.clipsToBounds = YES;
    _inner_view.layer.cornerRadius = 8;
    _inner_view.layoutMargins = UIEdgeInsetsMake(5, 5, 5, 5);
    
    _text_view = [UITextView new];
    _text_view.delegate = self;
    _text_view.font = [UIFont systemFontOfSize:14];
    
    _placeholder_label = [UILabel new];
    _placeholder_label.text = _placeholder;
    
    _spoiler_button = [UIButton new];
    [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    [_spoiler_button addTarget:self action:@selector(onSpoilerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _spoiler_button.contentMode = UIViewContentModeScaleToFill;
    
    _send_button = [UIButton new];
    [_send_button setImage:[UIImage systemImageNamed:@"arrow.up"] forState:UIControlStateNormal];
    [_send_button addTarget:self action:@selector(onSendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _send_button.contentMode = UIViewContentModeScaleToFill;
    _send_button.layer.cornerRadius = 20;
    
    [self addSubview:_inner_view];
    [_inner_view addSubview:_text_view];
    [_inner_view addSubview:_spoiler_button];
    [_text_view addSubview:_placeholder_label];
    [self addSubview:_send_button];
    
    _inner_view.translatesAutoresizingMaskIntoConstraints = NO;
    _text_view.translatesAutoresizingMaskIntoConstraints = NO;
    _spoiler_button.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholder_label.translatesAutoresizingMaskIntoConstraints = NO;
    _send_button.translatesAutoresizingMaskIntoConstraints = NO;
    
    _text_view_height_constraint = [_text_view.heightAnchor constraintEqualToConstant:40];
    [NSLayoutConstraint activateConstraints:@[
        [_inner_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_inner_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_inner_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_text_view.topAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_text_view.leadingAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.leadingAnchor],
        _text_view_height_constraint,
        [_text_view.bottomAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.bottomAnchor],
        
        [_placeholder_label.topAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.topAnchor],
        [_placeholder_label.leadingAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.leadingAnchor],
        [_placeholder_label.trailingAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.trailingAnchor],
        [_placeholder_label.bottomAnchor constraintLessThanOrEqualToAnchor:_text_view.layoutMarginsGuide.bottomAnchor],
        
        [_spoiler_button.topAnchor constraintGreaterThanOrEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_spoiler_button.leadingAnchor constraintEqualToAnchor:_text_view.trailingAnchor constant:5],
        [_spoiler_button.trailingAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.trailingAnchor],
        [_spoiler_button.widthAnchor constraintEqualToConstant:50],
        [_spoiler_button.heightAnchor constraintEqualToConstant:40],
        [_spoiler_button.bottomAnchor constraintEqualToAnchor:_inner_view.bottomAnchor],
        
        [_send_button.topAnchor constraintGreaterThanOrEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_send_button.leadingAnchor constraintEqualToAnchor:_inner_view.trailingAnchor constant:5],
        [_send_button.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_send_button.widthAnchor constraintEqualToConstant:40],
        [_send_button.heightAnchor constraintEqualToConstant:40],
        [_send_button.bottomAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.bottomAnchor],
    ]];
    [_text_view sizeToFit];
    [_text_view layoutSubviews];
    [_inner_view layoutSubviews];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _inner_view.backgroundColor = [AppColorProvider backgroundColor];
    _spoiler_button.tintColor = [AppColorProvider textSecondaryColor];
    _placeholder_label.textColor = [AppColorProvider textShyColor];
    _send_button.backgroundColor = [AppColorProvider primaryColor];
    _send_button.tintColor = [AppColorProvider textColor];
}
-(void)updateSpoilerState {
    if (_is_spoiler) {
        [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
        _spoiler_button.tintColor = [AppColorProvider primaryColor];
    } else {
        [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
        _spoiler_button.tintColor = [AppColorProvider textSecondaryColor];
    }
}

-(void)setText:(NSString*)text {
    _text_view.text = text;
    _placeholder_label.hidden = [_text_view.text length] != 0;
}
-(NSString*)getText {
    return _text_view.text;
}
-(void)setPlaceholder:(NSString*)placeholder {
    _placeholder = placeholder;
    if (_placeholder_label) {
        _placeholder_label.text = placeholder;
    }
}
-(void)endEditing:(BOOL)end_editing {
    [_text_view endEditing:end_editing];
}
-(void)startEditing {
    [_text_view becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView*)text_view {
    _text_view_height_constraint.constant = MAX(MIN(text_view.contentSize.height, 300), 40);
    _placeholder_label.hidden = [_text_view.text length] != 0;
}
-(IBAction)onSpoilerButtonPressed:(UIButton*)sender {
    _is_spoiler = !_is_spoiler;
    [self updateSpoilerState];
}
-(IBAction)onSendButtonPressed:(UIButton*)sender {
    [_delegate didSendPressedForTextEnterView:self];
}
@end
