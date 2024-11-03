//
//  AuthNavigationController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 21.08.2024.
//

#import <Foundation/Foundation.h>
#import "AuthNavigationController.h"
#import "AuthViewController.h"
#import "RestoreViewController.h"
#import "SignUpViewController.h"
#import "AuthChecker.h"

@interface AuthNavigationController ()
@end

@implementation AuthNavigationController

-(instancetype)init {
    [AuthChecker initialize];
    _auth_view_controller = [[AuthViewController alloc] initWithNavController:self];
    _restore_view_controller = [[RestoreViewController alloc] initWithNavController:self];
    _signup_view_controller = [[SignUpViewController alloc] initWithNavController:self];
    self = [super initWithRootViewController:_auth_view_controller];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)pushRestoreViewController {
    [self pushViewController:_restore_view_controller animated:YES];
}

-(void)pushSignUpViewController {
    [self pushViewController:_signup_view_controller animated:YES];
}

@end
