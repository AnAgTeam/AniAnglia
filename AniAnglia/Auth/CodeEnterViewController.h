//
//  CodeEnterViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.11.2025.
//

#ifndef CodeEnterViewController_h
#define CodeEnterViewController_h

#import <UIKit/UIKit.h>

@class CodeEnterViewController;

@protocol CodeEnterViewControllerDelegate <NSObject>

-(void)didResendForCodeEnterViewController:(CodeEnterViewController*)view_contoroller completionHandler:(void(^)(BOOL errored))completion_handler;
-(void)codeEnterViewController:(CodeEnterViewController*)view_contoroller didSubmitedCode:(NSString*)code completionHandler:(void(^)(BOOL errored))completion_handler;

@end

@interface CodeEnterViewController : UIViewController

@property(nonatomic, weak) id<CodeEnterViewControllerDelegate> delegate;

-(void)showCodeError:(NSString*)error_message;

@end


#endif /* CodeEnterViewController_h */
