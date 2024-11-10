//
//  NavigationAndSearchController.h
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <UIKit/UIKit.h>

@protocol NavigationSearchDelegate
@optional
-(void)searchBarFilterButtonPressed;
-(void)search:(NSString*)query;
@end

@interface NavigationSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak, setter = setSearchDelegate:) id<NavigationSearchDelegate> search_delegate;
@property(atomic) BOOL filter_enabled;
@property(atomic) BOOL history_enabled;
@property(nonatomic) UISearchBar* search_bar;

-(instancetype)init;
-(instancetype)initWithDelegate:(id<NavigationSearchDelegate>)view_controller filterEnabled:(BOOL)filter_enabled;
@end
