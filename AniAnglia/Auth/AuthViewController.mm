//
//  ViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 16.08.2024.
//

#import "AuthViewController.h"
#import "AppColor.h"
#import "UITextErrorField.h"
#import "AuthNavigationController.h"
#import "LibanixartApi.h"
#import "AppDataController.h"
#import "StringCvt.h"

@interface AuthViewController ()
@property(nonatomic, retain) AuthNavigationController* auth_nav_controller;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) AppDataController* data_controller;
@property(nonatomic, retain) UITextErrorField* login_view;
@property(nonatomic, retain) UITextField* login_field;
@property(nonatomic, retain) UITextErrorField* password_view;
@property(nonatomic, retain) UITextField* password_field;
@property(nonatomic, retain) UIButton* login_button;
@property(nonatomic, retain) UIActivityIndicatorView* login_indicator;
@property(nonatomic, retain) UIButton* forgot_button;
@property(nonatomic, retain) UIButton* signup_button;
@end

@implementation AuthViewController

-(instancetype)initWithNavController:(UINavigationController*)nav_controller {
    self = [super init];
    
    _auth_nav_controller = (AuthNavigationController*)nav_controller;
    _api_proxy = [LibanixartApi sharedInstance];
    _data_controller = [AppDataController sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _screen_width = UIScreen.mainScreen.bounds.size.width;
    _screen_height = UIScreen.mainScreen.bounds.size.height;
    
    [self setupView];
}

-(void)setupView {
    _login_view = [UITextErrorField new];
    _login_field = _login_view.field;
    [self.view addSubview:_login_view];
    _login_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_login_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_login_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_login_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.38 constant:0].active = YES;
    [_login_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _login_field.keyboardType = UIKeyboardTypeDefault;
    _login_field.placeholder = NSLocalizedString(@"app.auth.login_field.placeholder", "");
    _login_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _login_field.returnKeyType = UIReturnKeyDone;
    _login_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _login_field.textAlignment = NSTextAlignmentCenter;
    _login_field.borderStyle = UITextBorderStyleNone;
    _login_field.layer.cornerRadius = 8.0;
    _login_field.layer.borderWidth = 0.8;
    [_login_field setDelegate:self];
    
    _password_view = [UITextErrorField new];
    _password_field = _password_view.field;
    [self.view addSubview:_password_view];
    _password_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_password_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20.0].active = YES;
    [_password_view.heightAnchor constraintEqualToConstant:80.0].active = YES;
    [_password_view.topAnchor constraintEqualToAnchor:_login_view.bottomAnchor constant:5.0].active = YES;
    [_password_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    _password_field.keyboardType = UIKeyboardTypeDefault;
    _password_field.placeholder = NSLocalizedString(@"app.auth.password_field.placeholder", "");
    _password_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _password_field.returnKeyType = UIReturnKeyDone;
    _password_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _password_field.textAlignment = NSTextAlignmentCenter;
    _password_field.borderStyle = UITextBorderStyleNone;
    _password_field.layer.cornerRadius = 8.0;
    _password_field.layer.borderWidth = 0.8;
    [_password_field setSecureTextEntry:YES];
    [_password_field setDelegate:self];
    
    _login_button = [UIButton new];
    [self.view addSubview:_login_button];
    _login_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_login_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.45].active = YES;
    [_login_button.heightAnchor constraintEqualToConstant:50].active = YES;
    [_login_button.topAnchor constraintEqualToAnchor:_password_view.bottomAnchor constant:15.0].active = YES;
    [_login_button.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0].active = YES;
    [_login_button setTitle:NSLocalizedString(@"app.auth.login_button.normal.title", "") forState:UIControlStateNormal];
    _login_button.layer.cornerRadius = 8.0;
    [_login_button addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _login_indicator = [UIActivityIndicatorView new];
    [_login_button addSubview:_login_indicator];
    _login_indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem: _login_indicator attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem: _login_button attribute: NSLayoutAttributeBottom multiplier: 0.5 constant: 0].active = YES;
    [_login_indicator.leadingAnchor constraintEqualToAnchor:_login_button.leadingAnchor constant:15.0].active = YES;
    
    _forgot_button = [UIButton new];
    [self.view addSubview:_forgot_button];
    _forgot_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_forgot_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.45].active = YES;
    [_forgot_button.heightAnchor constraintEqualToConstant:30.0].active = YES;
    [_forgot_button.centerYAnchor constraintEqualToAnchor:_login_button.centerYAnchor].active = YES;
    [_forgot_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [_forgot_button setTitle:NSLocalizedString(@"app.auth.forgot_button.title", "") forState:UIControlStateNormal];
    [_forgot_button addTarget:self action:@selector(forgotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _signup_button = [UIButton new];
    [self.view addSubview:_signup_button];
    _signup_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_signup_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20].active = YES;
    [_signup_button.heightAnchor constraintEqualToConstant:30.0].active = YES;
    [_signup_button.topAnchor constraintEqualToAnchor:_login_button.bottomAnchor constant:40.0].active = YES;
    [_signup_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0].active = YES;
    [_signup_button setTitle:NSLocalizedString(@"app.auth.signup_button.title", "") forState:UIControlStateNormal];
    [_signup_button addTarget:self action:@selector(signUpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupDarkLayout];
}

-(void)setupDarkLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _login_field.textColor = [AppColorProvider textShyColor];
    _login_field.backgroundColor = [AppColorProvider foregroundColor1];
    _password_field.textColor = [AppColorProvider textShyColor];
    _password_field.backgroundColor = [AppColorProvider foregroundColor1];
    _login_button.backgroundColor = [AppColorProvider primaryColor];
    [_login_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    [_forgot_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
    [_signup_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
}

-(IBAction)loginButtonTapped:(id)sender {
    [_login_field resignFirstResponder];
    [_password_field resignFirstResponder];
    [_login_indicator startAnimating];
    
    using libanixart::codes::auth::SignInCode;
    std::string login = TO_STDSTRING(_login_field.text);
    std::string password = TO_STDSTRING(_password_field.text);
    libanixart::Api* api = _api_proxy.api;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            auto profile = api->auth().sign_in(login, password);
            self->_data_controller.token = TO_NSSTRING(profile->token.token);
            self->_api_proxy.api->set_token(profile->token.token);
        }
        catch (libanixart::SignInError& e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (e.code == SignInCode::InvalidLogin) {
                    [self->_login_view showError:NSLocalizedString(@"app.auth.login_field.error_invalid.text", "")];
                }
                else if (e.code == SignInCode::InvalidPassword) {
                    [self->_password_view showError:NSLocalizedString(@"app.auth.password_field.error_invalid.text", "")];
                }
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_login_indicator stopAnimating];
        });
    });
}
-(IBAction)forgotButtonTapped:(id)sender {
    [_auth_nav_controller pushRestoreViewController];
}
-(IBAction)signUpButtonTapped:(id)sender {
    [_auth_nav_controller pushSignUpViewController];
}

-(void)textFieldDidBeginEditing:(UITextField *)text_field {
    if (text_field == _login_field) {
        [_login_view clearError];
    }
    else if (text_field == _password_field) {
        [_password_view clearError];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)text_field reason:(UITextFieldDidEndEditingReason)reason {
    if ([text_field.text length] == 0) {
        if (text_field == _login_field) {
            [_login_view showError:NSLocalizedString(@"app.auth.login_field.error_empty.text", "")];
        }
        else if (text_field == _password_field) {
            [_password_view showError:NSLocalizedString(@"app.auth.password_field.error_empty.text", "")];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)text_field {
    [text_field resignFirstResponder];
    return NO;
}

@end
