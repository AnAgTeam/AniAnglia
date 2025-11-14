//
//  SignUpViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 23.08.2024.
//

#import <Foundation/Foundation.h>
#import "SignUpViewController.h"
#import "TextErrorField.h"
#import "AppColor.h"
#import "AuthChecker.h"
#import "CodeEnterViewController.h"
#import "AuthPerformer.h"
#import "StringCvt.h"

@interface SignUpViewController () <CodeEnterViewControllerDelegate> {
    anixart::ApiAuthPending::UPtr _pending_signup;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) AuthChecker* auth_checker;
@property(nonatomic, retain) TextErrorField* login_view;
@property(nonatomic, retain) UITextField* login_field;
@property(nonatomic, retain) TextErrorField* email_view;
@property(nonatomic, retain) UITextField* email_field;
@property(nonatomic, retain) TextErrorField* password_view;
@property(nonatomic, retain) UITextField* password_field;
@property(nonatomic, retain) TextErrorField* password_re_view;
@property(nonatomic, retain) UITextField* password_re_field;
@property(nonatomic, retain) UIButton* signup_button;
@property(nonatomic, retain) UIActivityIndicatorView* activity_indicator_view;


@end

@implementation SignUpViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _auth_checker = [AuthChecker new];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _login_view = [TextErrorField new];
    _login_field = _login_view.field;
    _login_field.keyboardType = UIKeyboardTypeDefault;
    _login_field.placeholder = NSLocalizedString(@"app.auth.username", "");
    _login_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _login_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _login_field.returnKeyType = UIReturnKeyDone;
    _login_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _login_field.textAlignment = NSTextAlignmentCenter;
    _login_field.borderStyle = UITextBorderStyleNone;
    _login_field.layer.cornerRadius = 8.0;
    _login_field.layer.borderWidth = 0.8;
    [_login_field setDelegate:self];
    
    _email_view = [TextErrorField new];
    _email_field = _email_view.field;
    _email_field.keyboardType = UIKeyboardTypeDefault;
    _email_field.placeholder = NSLocalizedString(@"app.auth.email", "");
    _email_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _email_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _email_field.returnKeyType = UIReturnKeyDone;
    _email_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _email_field.textAlignment = NSTextAlignmentCenter;
    _email_field.borderStyle = UITextBorderStyleNone;
    _email_field.layer.cornerRadius = 8.0;
    _email_field.layer.borderWidth = 0.8;
    [_email_field setDelegate:self];
    
    _password_view = [TextErrorField new];
    _password_field = _password_view.field;
    _password_field.keyboardType = UIKeyboardTypeDefault;
    _password_field.placeholder = NSLocalizedString(@"app.auth.password", "");
    _password_field.autocorrectionType = UITextAutocorrectionTypeNo;
    _password_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password_field.returnKeyType = UIReturnKeyDone;
    _password_field.clearButtonMode = UITextFieldViewModeWhileEditing;
    _password_field.textAlignment = NSTextAlignmentCenter;
    _password_field.borderStyle = UITextBorderStyleNone;
    _password_field.layer.cornerRadius = 8.0;
    _password_field.layer.borderWidth = 0.8;
    [_password_field setSecureTextEntry:YES];
    [_password_field setDelegate:self];
    
    _password_re_view = [TextErrorField new];
    _password_re_field = _password_re_view.field;
    _password_re_field.keyboardType = UIKeyboardTypeDefault;
    _password_re_field.placeholder = NSLocalizedString(@"app.auth.password_re", "");
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
    [_signup_button setTitle:NSLocalizedString(@"app.auth.sign_up.confirm", "") forState:UIControlStateNormal];
    _signup_button.layer.cornerRadius = 8.0;
    [_signup_button addTarget:self action:@selector(signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _activity_indicator_view = [UIActivityIndicatorView new];
    
    [self.view addSubview:_login_view];
    [self.view addSubview:_password_re_view];
    [self.view addSubview:_password_view];
    [self.view addSubview:_email_view];
    [self.view addSubview:_signup_button];
    [self.view addSubview:_activity_indicator_view];
    
    _login_view.translatesAutoresizingMaskIntoConstraints = NO;
    _password_re_view.translatesAutoresizingMaskIntoConstraints = NO;
    _password_view.translatesAutoresizingMaskIntoConstraints = NO;
    _email_view.translatesAutoresizingMaskIntoConstraints = NO;
    _signup_button.translatesAutoresizingMaskIntoConstraints = NO;
    _activity_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_login_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_login_view.heightAnchor constraintEqualToConstant:80.0],
        [NSLayoutConstraint constraintWithItem:_login_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:0.28 constant:0],
        [_login_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_password_re_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_password_re_view.heightAnchor constraintEqualToConstant:80.0],
        [_password_re_view.topAnchor constraintEqualToAnchor:_password_view.bottomAnchor constant:5.0],
        [_password_re_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_password_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_password_view.heightAnchor constraintEqualToConstant:80.0],
        [_password_view.topAnchor constraintEqualToAnchor:_email_view.bottomAnchor constant:5.0],
        [_password_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_email_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_email_view.heightAnchor constraintEqualToConstant:80.0],
        [_email_view.topAnchor constraintEqualToAnchor:_login_view.bottomAnchor constant:5.0],
        [_email_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_signup_button.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-20],
        [_signup_button.heightAnchor constraintEqualToConstant:50],
        [_signup_button.topAnchor constraintEqualToAnchor:_password_re_view.bottomAnchor constant:15.0],
        [_signup_button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        
        [_activity_indicator_view.centerYAnchor constraintEqualToAnchor:_signup_button.centerYAnchor],
        [_activity_indicator_view.trailingAnchor constraintEqualToAnchor:_signup_button.layoutMarginsGuide.trailingAnchor]
    ]];
}

-(void)setupLayout {
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

-(BOOL)checkFieldAndShowError:(UITextField*)text_field {
    if (text_field == _login_field) {
        if ([_login_field.text length] == 0) {
            [_login_view showError:NSLocalizedString(@"app.auth.username.error.empty", "")];
            return NO;
        }
        AuthCheckerStatus check_status = [_auth_checker checkUsername:_login_field.text];
        if (check_status == AuthCheckerStatus::TooLong) {
            [_login_view showError:NSLocalizedString(@"app.auth.username.error.long", "")];
            return NO;
        }
    }
    else if (text_field == _email_field) {
        if ([_email_field.text length] == 0) {
            [_email_view showError:NSLocalizedString(@"app.auth.email.error.empty", "")];
            return NO;
        }
        AuthCheckerStatus check_status = [_auth_checker checkEmail:_email_field.text];
        if (check_status == AuthCheckerStatus::Invalid) {
            [_email_view showError:NSLocalizedString(@"app.auth.email.error.invalid", "")];
            return NO;
        }
    }
    else if (text_field == _password_field) {
        AuthCheckerStatus check_status = [_auth_checker checkPassword:_password_field.text];
        if (check_status == AuthCheckerStatus::TooShort) {
            [_password_view showError:NSLocalizedString(@"app.auth.password.error.short", "")];
        }
        else if (check_status == AuthCheckerStatus::TooLong) {
            [_password_view showError:NSLocalizedString(@"app.auth.password.error.long", "")];
        }
        else if (check_status == AuthCheckerStatus::Invalid) {
            [_password_view showError:NSLocalizedString(@"app.auth.password.error.invalid", "")];
        }
        return check_status == AuthCheckerStatus::Normal;
    }
    else if (text_field == _password_re_field) {
        if (![_password_field.text isEqualToString:_password_re_field.text]) {
            [_password_re_view showError:NSLocalizedString(@"app.auth.password.error.not_equal", "")];
            return NO;
        }
    }
    return YES;
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
    [self checkFieldAndShowError:text_field];
}

-(BOOL)textFieldShouldReturn:(UITextField *)text_field {
    [text_field resignFirstResponder];
    return NO;
}

-(IBAction)signupButtonTapped:(id)sender {
    if (![self checkFieldAndShowError:_login_field] ||
        ![self checkFieldAndShowError:_email_field] ||
        ![self checkFieldAndShowError:_password_field] ||
        ![self checkFieldAndShowError:_password_re_field]) {
        return;
    }
    using anixart::codes::auth::SignUpCode;
    
    std::string username = TO_STDSTRING(_login_field.text);
    std::string email = TO_STDSTRING(_email_field.text);
    std::string password = TO_STDSTRING(_password_field.text);
    __block SignUpCode error_code = SignUpCode::Success;
    
    [_activity_indicator_view startAnimating];
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        try {
            self->_pending_signup = api->auth().sign_up(username, email, password);
        } catch (const anixart::SignUpError& e) {
            error_code = e.code;
            return YES;
        }
        return NO;
    } completion:^(BOOL errored) {
        [self->_activity_indicator_view stopAnimating];
        if (!errored || error_code == SignUpCode::CodeAlreadySent) {
            CodeEnterViewController* view_controller = [CodeEnterViewController new];
            view_controller.delegate = self;
            if (error_code == SignUpCode::CodeAlreadySent) {
                [view_controller showCodeError:NSLocalizedString(@"app.auth.error.code_already_sent", "")];
            }
            [self.navigationController pushViewController:view_controller animated:YES];
            return;
        }
        
        if (error_code == SignUpCode::LoginAlreadyTaken) {
            [self->_login_view showError:NSLocalizedString(@"app.auth.error.username_taken", "")];
            return;
        }
        if (error_code == SignUpCode::EmailAlreadyTaken) {
            [self->_email_view showError:NSLocalizedString(@"app.auth.error.email_taken", "")];
            return;
        }
        if (error_code == SignUpCode::EmailServiceDisallowed) {
            [self->_email_view showError:NSLocalizedString(@"app.auth.error.email_service_disallowed", "")];
            return;
        }
        
        NSString* error_msg = nil;
        switch (error_code) {
            case SignUpCode::CodeCannotSend:
                error_msg = NSLocalizedString(@"app.auth.error.cannot_send_code", "");
                break;
            case SignUpCode::TooManyRegistrations:
                error_msg = NSLocalizedString(@"app.auth.error.too_many_registrations", "");
                break;
            default:
                error_msg = NSLocalizedString(@"app.auth.error.unknown", "");
                break;
        }
        
        UIAlertController* alert_controller = [UIAlertController alertControllerWithTitle:error_msg message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert_controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"app.auth.action_ok", "") style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
            
        }]];
        [self presentViewController:alert_controller animated:YES completion:nil];
    }];
}

-(void)didResendForCodeEnterViewController:(CodeEnterViewController*)view_contoroller completionHandler:(void (^)(BOOL))completion_handler {
    using anixart::codes::auth::ResendCode;
    
    __block ResendCode error_code = ResendCode::Success;
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        try {
            self->_pending_signup->resend();
        } catch (const anixart::ResendError& e) {
            error_code = e.code;
            return YES;
        }
        return NO;
    } completion:^(BOOL errored) {
        completion_handler(errored);
        if (!errored) {
            return;
        }
        
        NSString* error_msg = nil;
        switch (error_code) {
            case ResendCode::CodeCannotSend:
                error_msg = NSLocalizedString(@"app.auth.error.cannot_send_code", "");
                break;
            default:
                error_msg = NSLocalizedString(@"app.auth.error.unknown", "");
                break;
        }
        
        [view_contoroller showCodeError:error_msg];
    }];
}

-(void)codeEnterViewController:(CodeEnterViewController*)view_contoroller didSubmitedCode:(NSString *)code completionHandler:(void (^)(BOOL))completion_handler {
    using anixart::codes::auth::VerifyCode;
    
    std::string signup_code = TO_STDSTRING(code);
    __block anixart::Profile::Ptr profile;
    __block anixart::ProfileToken profile_token;
    __block VerifyCode error_code = VerifyCode::Success;
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        try {
            auto signup_ret = self->_pending_signup->verify(signup_code);
            profile = std::move(signup_ret.first);
            profile_token = std::move(signup_ret.second);
        } catch(const anixart::VerifyError& e) {
            error_code = e.code;
            return YES;
        }
        return NO;
    } completion:^(BOOL errored) {
        completion_handler(errored);
        if (!errored) {
            [AuthPerformer performAuthWithProfile:profile profileToken:std::move(profile_token)];
            return;
        }
        
        NSString* error_msg = nil;
        switch(error_code) {
            case VerifyCode::CodeExpired:
                error_msg = NSLocalizedString(@"app.auth.error.code_expired", "");
                break;
            case VerifyCode::CodeInvalid:
                error_msg = NSLocalizedString(@"app.auth.error.code_invalid", "");
                break;
            default:
                error_msg = NSLocalizedString(@"app.auth.error.unknown", "");
                break;
        }
        
        [view_contoroller showCodeError:error_msg];
    }];
}

@end
