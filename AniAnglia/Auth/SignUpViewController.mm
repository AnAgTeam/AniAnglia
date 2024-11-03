//
//  SignUpViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 23.08.2024.
//

#import <Foundation/Foundation.h>
#import "SignUpViewController.h"
#import "UITextErrorField.h"
#import "AuthNavigationController.h"
#import "AppColor.h"
#import "AuthChecker.h"

@interface SignUpViewController ()
@property(nonatomic, retain) AuthNavigationController* auth_nav_controller;
@property(nonatomic, retain) AuthChecker* auth_checker;
@property(nonatomic, retain) UITextErrorField* login_view;
@property(nonatomic, retain) UITextField* login_field;
@property(nonatomic, retain) UITextErrorField* email_view;
@property(nonatomic, retain) UITextField* email_field;
@property(nonatomic, retain) UITextErrorField* password_view;
@property(nonatomic, retain) UITextField* password_field;
@property(nonatomic, retain) UITextErrorField* password_re_view;
@property(nonatomic, retain) UITextField* password_re_field;
@property(nonatomic, retain) UIButton* signup_button;
@end

@implementation SignUpViewController

-(instancetype)initWithNavController:(UINavigationController*)nav_controller {
    self = [super init];
    
    _auth_nav_controller = (AuthNavigationController*)nav_controller;
    _auth_checker = [AuthChecker new];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    _login_view = [UITextErrorField new];
    _login_field = _login_view.field;
    [self.view addSubview:_login_view];
    _login_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_login_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_login_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_login_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.28 constant:0].active = YES;
    [_login_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _login_field.keyboardType = UIKeyboardTypeDefault;
    _login_field.placeholder = NSLocalizedString(@"app.signup.login_field.placeholder", "");
    _login_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _login_field.returnKeyType = UIReturnKeyDone;
    _login_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _login_field.textAlignment = NSTextAlignmentCenter;
    _login_field.borderStyle = UITextBorderStyleNone;
    _login_field.layer.cornerRadius = 8.0;
    _login_field.layer.borderWidth = 0.8;
    [_login_field setDelegate:self];
    
    _email_view = [UITextErrorField new];
    _email_field = _email_view.field;
    [self.view addSubview:_email_view];
    _email_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_email_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_email_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [_email_view.topAnchor constraintEqualToAnchor:_login_view.bottomAnchor constant:5.0].active = YES;
    [_email_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _email_field.keyboardType = UIKeyboardTypeDefault;
    _email_field.placeholder = NSLocalizedString(@"app.signup.email_field.placeholder", "");
    _email_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _email_field.returnKeyType = UIReturnKeyDone;
    _email_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _email_field.textAlignment = NSTextAlignmentCenter;
    _email_field.borderStyle = UITextBorderStyleNone;
    _email_field.layer.cornerRadius = 8.0;
    _email_field.layer.borderWidth = 0.8;
    [_email_field setDelegate:self];
    
    _password_view = [UITextErrorField new];
    _password_field = _password_view.field;
    [self.view addSubview:_password_view];
    _password_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_password_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_password_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [_password_view.topAnchor constraintEqualToAnchor:_email_view.bottomAnchor constant:5.0].active = YES;
    [_password_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _password_field.keyboardType = UIKeyboardTypeDefault;
    _password_field.placeholder = NSLocalizedString(@"app.signup.password_field.placeholder", "");
    _password_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _password_field.returnKeyType = UIReturnKeyDone;
    _password_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _password_field.textAlignment = NSTextAlignmentCenter;
    _password_field.borderStyle = UITextBorderStyleNone;
    _password_field.layer.cornerRadius = 8.0;
    _password_field.layer.borderWidth = 0.8;
    [_password_field setSecureTextEntry:YES];
    [_password_field setDelegate:self];
    
    _password_re_view = [UITextErrorField new];
    _password_re_field = _password_re_view.field;
    [self.view addSubview:_password_re_view];
    _password_re_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_password_re_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_password_re_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [_password_re_view.topAnchor constraintEqualToAnchor:_password_view.bottomAnchor constant:5.0].active = YES;
    [_password_re_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _password_re_field.keyboardType = UIKeyboardTypeDefault;
    _password_re_field.placeholder = NSLocalizedString(@"app.restore.password_re_field.placeholder", "");
    _password_re_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _password_re_field.returnKeyType = UIReturnKeyDone;
    _password_re_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _password_re_field.textAlignment = NSTextAlignmentCenter;
    _password_re_field.borderStyle = UITextBorderStyleNone;
    _password_re_field.layer.cornerRadius = 8.0;
    _password_re_field.layer.borderWidth = 0.8;
    [_password_re_field setSecureTextEntry:YES];
    [_password_re_field setDelegate:self];
    
    _signup_button = [UIButton new];
    [self.view addSubview:_signup_button];
    _signup_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_signup_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_signup_button.heightAnchor constraintEqualToConstant:50].active = YES;
    [_signup_button.topAnchor constraintEqualToAnchor:_password_re_view.bottomAnchor constant:15.0].active = YES;
    [_signup_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [_signup_button setTitle:NSLocalizedString(@"app.signup.signup_button.normal.title", "") forState:UIControlStateNormal];
    _signup_button.layer.cornerRadius = 8.0;
    [_signup_button addTarget:self action:@selector(signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupDarkLayout];
}

-(void)setupDarkLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _login_field.textColor = [AppColorProvider textShyColor];
    _login_field.backgroundColor = [AppColorProvider foregroundColor1];
    _email_field.textColor = [AppColorProvider textShyColor];
    _email_field.backgroundColor = [AppColorProvider foregroundColor1];
    _password_field.textColor = [AppColorProvider textShyColor];
    _password_field.backgroundColor = [AppColorProvider foregroundColor1];
    _password_re_field.textColor = [AppColorProvider textShyColor];
    _password_re_field.backgroundColor = [AppColorProvider foregroundColor1];
    _signup_button.backgroundColor = [AppColorProvider primaryColor];
}

-(IBAction)signupButtonTapped:(id)sender {
    
}

-(void)textFieldDidBeginEditing:(UITextField *)text_field {
    if (text_field == _login_field) {
        [_login_view clearError];
    }
    else if (text_field == _email_field) {
        [_email_view clearError];
    }
    else if (text_field == _password_field) {
        [_password_view clearError];
    }
    else if (text_field == _password_re_field) {
        [_password_re_view clearError];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)text_field reason:(UITextFieldDidEndEditingReason)reason {
    if (text_field == _login_field) {
        if ([_login_field.text length] == 0) {
            [_login_view showError:NSLocalizedString(@"app.signup.login_field.error_empty.text", "")];
            return;
        }
        AuthCheckerStatus check_status = [_auth_checker checkUsername:_login_field.text];
        if (check_status == AuthCheckerStatus::TooLong) {
            [_login_view showError:NSLocalizedString(@"app.signup.login_field.error_long.text", "")];
        }
    }
    else if (text_field == _email_field) {
        if ([_email_field.text length] == 0) {
            [_email_view showError:NSLocalizedString(@"app.signup.email_field.error_empty.text", "")];
            return;
        }
        AuthCheckerStatus check_status = [_auth_checker checkEmail:_email_field.text];
        if (check_status == AuthCheckerStatus::Invalid) {
            [_email_view showError:NSLocalizedString(@"app.signup.email_field.error_invalid.text", "")];
        }
    }
    else if (text_field == _password_field) {
        AuthCheckerStatus check_status = [_auth_checker checkPassword:_password_field.text];
        if (check_status == AuthCheckerStatus::TooShort) {
            [_password_view showError:NSLocalizedString(@"app.signup.password_field.error_short.text", "")];
        }
        else if (check_status == AuthCheckerStatus::TooLong) {
            [_password_view showError:NSLocalizedString(@"app.signup.password_field.error_long.text", "")];
        }
        else if (check_status == AuthCheckerStatus::Invalid) {
            [_password_view showError:NSLocalizedString(@"app.signup.password_field.error_invalid.text", "")];
        }
    }
    else if (text_field == _password_re_field) {
        if (![_password_field.text isEqualToString:_password_re_field.text]) {
            [_password_re_view showError:NSLocalizedString(@"app.signup.password_re_field.error_not_equal.text", "")];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)text_field {
    [text_field resignFirstResponder];
    return NO;
}

@end
