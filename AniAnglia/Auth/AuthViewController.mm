//
//  ViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 16.08.2024.
//

#import "AuthViewController.h"
#import "AppColor.h"
#import "TextErrorField.h"
#import "LibanixartApi.h"
#import "AppDataController.h"
#import "StringCvt.h"
#import "RestoreViewController.h"
#import "SignUpViewController.h"
#import "MainWindow.h"
#import "MainTabBarController.h"

@interface AuthViewController ()
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) AppDataController* data_controller;
@property(nonatomic, retain) TextErrorField* login_view;
@property(nonatomic, retain) UITextField* login_field;
@property(nonatomic, retain) TextErrorField* password_view;
@property(nonatomic, retain) UITextField* password_field;
@property(nonatomic, retain) UIButton* login_button;
@property(nonatomic, retain) UIActivityIndicatorView* login_indicator;
@property(nonatomic, retain) UIButton* forgot_button;
@property(nonatomic, retain) UIButton* signup_button;
@end

@implementation AuthViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _data_controller = [AppDataController sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _screen_width = UIScreen.mainScreen.bounds.size.width;
    _screen_height = UIScreen.mainScreen.bounds.size.height;
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _login_view = [TextErrorField new];
    _login_field = _login_view.field;
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
    
    _password_view = [TextErrorField new];
    _password_field = _password_view.field;
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
    [_login_button setTitle:NSLocalizedString(@"app.auth.login_button.normal.title", "") forState:UIControlStateNormal];
    _login_button.layer.cornerRadius = 8.0;
    [_login_button addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _login_indicator = [UIActivityIndicatorView new];
    
    _forgot_button = [UIButton new];
    [_forgot_button setTitle:NSLocalizedString(@"app.auth.forgot_button.title", "") forState:UIControlStateNormal];
    [_forgot_button addTarget:self action:@selector(forgotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _signup_button = [UIButton new];
    [_signup_button setTitle:NSLocalizedString(@"app.auth.signup_button.title", "") forState:UIControlStateNormal];
    [_signup_button addTarget:self action:@selector(signUpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_login_view];
    [self.view addSubview:_password_view];
    [self.view addSubview:_login_button];
    [_login_button addSubview:_login_indicator];
    [self.view addSubview:_forgot_button];
    [self.view addSubview:_signup_button];
    
    _login_view.translatesAutoresizingMaskIntoConstraints = NO;
    _password_view.translatesAutoresizingMaskIntoConstraints = NO;
    _login_button.translatesAutoresizingMaskIntoConstraints = NO;
    _login_indicator.translatesAutoresizingMaskIntoConstraints = NO;
    _forgot_button.translatesAutoresizingMaskIntoConstraints = NO;
    _signup_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_login_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_login_view.heightAnchor constraintEqualToConstant:80.0],
        [NSLayoutConstraint constraintWithItem:_login_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.38 constant:0],
        [_login_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_password_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20.0],
        [_password_view.heightAnchor constraintEqualToConstant:80.0],
        [_password_view.topAnchor constraintEqualToAnchor:_login_view.bottomAnchor constant:5.0],
        [_password_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_login_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.45],
        [_login_button.heightAnchor constraintEqualToConstant:50],
        [_login_button.topAnchor constraintEqualToAnchor:_password_view.bottomAnchor constant:15.0],
        [_login_button.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0],
        
        [NSLayoutConstraint constraintWithItem: _login_indicator attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem: _login_button attribute: NSLayoutAttributeBottom multiplier: 0.5 constant: 0],
        [_login_indicator.leadingAnchor constraintEqualToAnchor:_login_button.leadingAnchor constant:15.0],
        
        [_forgot_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.45],
        [_forgot_button.heightAnchor constraintEqualToConstant:30.0],
        [_forgot_button.centerYAnchor constraintEqualToAnchor:_login_button.centerYAnchor],
        [_forgot_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_signup_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_signup_button.heightAnchor constraintEqualToConstant:30.0],
        [_signup_button.topAnchor constraintEqualToAnchor:_login_button.bottomAnchor constant:40.0],
        [_signup_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0]
    ]];
}

-(void)setupLayout {
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
    if (![self checkAllFieldsIsCorrect]) {
        return;
    }
    [_login_field resignFirstResponder];
    [_password_field resignFirstResponder];
    [_login_indicator startAnimating];
    
    std::string login = TO_STDSTRING(_login_field.text);
    std::string password = TO_STDSTRING(_password_field.text);
    __block BOOL errored = NO;
    __block anixart::codes::auth::SignInCode error_code;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        // TODO: change api to always execute UICompletion block and return error
        try {
            auto [profile, token] = api->auth().sign_in(login, password);
            [self->_data_controller setToken:TO_NSSTRING(token.token)];
            [self->_data_controller setMyProfileID:profile->id];
            self->_api_proxy.api->set_token(token.token);
        }
        catch (anixart::SignInError& e) {
            errored = YES;
            error_code = e.code;
        }
        return YES;
    } withUICompletion:^{
        [self->_login_indicator stopAnimating];
        if (errored) {
            if (error_code == anixart::codes::auth::SignInCode::InvalidLogin) {
                [self->_login_view showError:NSLocalizedString(@"app.auth.login_field.error_invalid.text", "")];
            }
            else if (error_code == anixart::codes::auth::SignInCode::InvalidPassword) {
                [self->_password_view showError:NSLocalizedString(@"app.auth.password_field.error_invalid.text", "")];
            }
        } else {
            [self setRootViewControllerToMain];
        }
    }];
}
-(IBAction)forgotButtonTapped:(id)sender {
    [self.navigationController pushViewController:[RestoreViewController new] animated:YES];
}
-(IBAction)signUpButtonTapped:(id)sender {
    [self.navigationController pushViewController:[SignUpViewController new] animated:YES];
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
    [self checkAllFieldsIsCorrect];
}

-(BOOL)textFieldShouldReturn:(UITextField *)text_field {
    [text_field resignFirstResponder];
    return NO;
}

-(void)setRootViewControllerToMain {
    MainWindow* main_window = (MainWindow*)[[[UIApplication sharedApplication] delegate] window];
    [main_window setRootViewController:[MainTabBarController new]];
}

-(BOOL)checkAllFieldsIsCorrect {
    BOOL is_all_corrent = YES;
    if ([_login_field.text length] == 0) {
        [_login_view showError:NSLocalizedString(@"app.auth.login_field.error_empty.text", "")];
        is_all_corrent = NO;
    }
    if ([_password_field.text length] == 0) {
        [_password_view showError:NSLocalizedString(@"app.auth.password_field.error_empty.text", "")];
        is_all_corrent = NO;
    }
    return is_all_corrent;
}

@end
