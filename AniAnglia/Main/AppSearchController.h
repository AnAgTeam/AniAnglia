//
//  AppSearchBarController.h
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <UIKit/UIKit.h>

@interface AppSearchBar : UISearchBar
@property(nonatomic, retain) UIButton* cancel_button;
@property(nonatomic, retain) UIButton* filter_button;

@property(nonatomic, weak, setter = setDelegate:, getter = delegate) id<UISearchBarDelegate> delegate;

-(id<UISearchBarDelegate>)delegate;
-(void)setDelegate:(id<UISearchBarDelegate>)delegate;
@end

@interface AppSearchController : UISearchController <UISearchBarDelegate>

@property(nonatomic, retain) AppSearchBar* search_bar;

-(instancetype)initWithPlaceholder:(NSString*)placeholder;

@end

//@interface AppSearchViewController : UIViewController
//
//@property(nonatomic, retain) AppSearchController* search_controller;
//
//-(instancetype)initWithRootViewController:(UIViewController*)view_controller;
//-(void)set
//
//@end
