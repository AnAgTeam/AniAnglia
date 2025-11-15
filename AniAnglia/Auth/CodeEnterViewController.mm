//
//  CodeEnterViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.11.2025.
//

#import <Foundation/Foundation.h>
#import "CodeEnterViewController.h"
#import "TextErrorField.h"
#import "AppColor.h"

@interface CodeEnterViewController () <UITextFieldDelegate>
@property(nonatomic, retain) TextErrorField* code_view;
@property(nonatomic, retain) UITextField* code_field;
@property(nonatomic, retain) UILabel* check_spam_label;
@property(nonatomic, retain) UIButton* resend_button;
@property(nonatomic, retain) UIButton* submit_button;
@property(nonatomic, retain) UIActivityIndicatorView* activity_indicator_view;
@property(nonatomic, retain) NSString* code_error_text;

@end

@implementation CodeEnterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setuo];
    [self setupLayout];
}

-(void)setuo {
    _code_view = [TextErrorField new];
    _code_field = _code_view.field;
    _code_field.keyboardType = UIKeyboardTypeDefault;
    _code_field.placeholder = NSLocalizedString(@"app.code_enter.code_enter", "");
    _code_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _code_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _code_field.returnKeyType = UIReturnKeyDone;
    _code_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _code_field.textAlignment = NSTextAlignmentCenter;
    _code_field.borderStyle = UITextBorderStyleNone;
    _code_field.layer.cornerRadius = 8.0;
    _code_field.layer.borderWidth = 0.8;
    _code_field.delegate = self;
    
    _check_spam_label = [UILabel new];
    _check_spam_label.text = NSLocalizedString(@"app.auth.check_spam", "");
    
    _resend_button = [UIButton new];
    _resend_button.layer.cornerRadius = 8.0;
    [_resend_button setTitle:NSLocalizedString(@"app.code_enter.resend", "") forState:UIControlStateNormal];
    [_resend_button addTarget:self action:@selector(onResendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _submit_button = [UIButton new];
    _submit_button.layer.cornerRadius = 8.0;
    [_submit_button setTitle:NSLocalizedString(@"app.code_enter.submit", "") forState:UIControlStateNormal];
    [_submit_button addTarget:self action:@selector(onSubmitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _activity_indicator_view = [UIActivityIndicatorView new];
    
    [self.view addSubview:_code_view];
    [self.view addSubview:_check_spam_label];
    [self.view addSubview:_resend_button];
    [self.view addSubview:_submit_button];
    [self.view addSubview:_activity_indicator_view];
    
    _code_view.translatesAutoresizingMaskIntoConstraints = NO;
    _check_spam_label.translatesAutoresizingMaskIntoConstraints = NO;
    _resend_button.translatesAutoresizingMaskIntoConstraints = NO;
    _submit_button.translatesAutoresizingMaskIntoConstraints = NO;
    _activity_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_code_view.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [_code_view.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [_code_view.heightAnchor constraintEqualToConstant:80.0],
        
        [_check_spam_label.topAnchor constraintEqualToAnchor:_code_view.bottomAnchor constant:8],
        [_check_spam_label.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [_check_spam_label.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        
        [_resend_button.topAnchor constraintEqualToAnchor:_check_spam_label.bottomAnchor constant:8],
        [_resend_button.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [_resend_button.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [_resend_button.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor],
        [_resend_button.heightAnchor constraintEqualToConstant:60.0],
        
        [_submit_button.topAnchor constraintEqualToAnchor:_resend_button.bottomAnchor constant:8],
        [_submit_button.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [_submit_button.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [_submit_button.heightAnchor constraintEqualToConstant:50.0],
        
        [_activity_indicator_view.topAnchor constraintEqualToAnchor:_submit_button.bottomAnchor constant:10.0],
        [_activity_indicator_view.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
    ]];
    
    if (_code_error_text) {
        [_code_view showError:_code_error_text];
    }
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _code_field.textColor = [AppColorProvider textShyColor];
    _code_field.backgroundColor = [AppColorProvider foregroundColor1];
    [_resend_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
    _submit_button.backgroundColor = [AppColorProvider primaryColor];
}

-(void)showCodeError:(NSString*)error_message {
    if (!_code_view) {
        _code_error_text = error_message;
        return;
    }
    if (error_message) {
        [_code_view showError:error_message];
    } else {
        [_code_view clearError];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)text_field {
    [text_field resignFirstResponder];
    return NO;
}

-(IBAction)onResendButtonPressed:(UIButton*)sender {
    [_activity_indicator_view startAnimating];
    [_delegate didResendForCodeEnterViewController:self completionHandler:^(BOOL errored) {
        [self->_activity_indicator_view stopAnimating];
    }];
}

-(IBAction)onSubmitButtonPressed:(UIButton*)sender {
    [_activity_indicator_view startAnimating];
    [_delegate codeEnterViewController:self didSubmitedCode:_code_field.text completionHandler:^(BOOL errored) {
        [self->_activity_indicator_view stopAnimating];
    }];
}

@end
