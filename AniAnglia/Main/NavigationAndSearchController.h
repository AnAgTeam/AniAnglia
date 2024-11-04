//
//  NavigationAndSearchController.h
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <UIKit/UIKit.h>

@protocol NavigationSearchDelegate
-(void)searchBarFilterButtonPressed;
-(void)search:(NSString*)query;
@end

@interface NavigationSearchController : UINavigationController <UISearchBarDelegate>
@property(nonatomic, weak) UIViewController<NavigationSearchDelegate>* search_delegate;
@property(nonatomic, readonly, getter = searchBar) UISearchBar* search_bar;

-(instancetype)initWithDelegateRootViewController:(UIViewController<NavigationSearchDelegate>*)view_controller filterEnabled:(BOOL)filter_enabled;
-(UISearchBar*)searchBar;
@end
