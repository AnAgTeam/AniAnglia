//
//  ViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 16.08.2024.
//

#import <UIKit/UIKit.h>
#import "TextErrorField.h"

@interface AuthViewController : UIViewController <UITextFieldDelegate> {
    CGFloat _screen_width;
    CGFloat _screen_height;
}

-(instancetype)init;

@end

