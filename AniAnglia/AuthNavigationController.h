//
//  AuthNavigationController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 21.08.2024.
//

#import <UIKit/UIKit.h>

@interface AuthNavigationController : UINavigationController <UINavigationControllerDelegate>
@property(nonatomic, retain) UIViewController* auth_view_controller;
@property(nonatomic, retain) UIViewController* restore_view_controller;
@property(nonatomic, retain) UIViewController* signup_view_controller;

-(instancetype)init;
-(void)pushRestoreViewController;
-(void)pushSignUpViewController;
@end
