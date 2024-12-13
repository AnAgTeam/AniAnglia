//
//  NavigationAndSearchController.h
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <UIKit/UIKit.h>

@class NavigationSearchViewController;

@protocol NavigationSearchDelegate
@optional
-(void)searchBarFilterButtonPressed;
-(void)search:(NSString*)query;
@end

@interface NavigationSearchInlineView : UIView
-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller;
-(void)searchTextDidChanged:(NSString*)text;
-(void)searchViewDidCancelWithText:(NSString*)text isSearchQuery:(BOOL)is_search_query;
@end

@interface NavigationSearchView : UIView
-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller query:(NSString*)query;
-(void)reloadWithText:(NSString*)text;
@end

@interface NavigationSearchViewController : UIViewController <UISearchBarDelegate>
@property(nonatomic, weak, setter = setSearchDelegate:) id<NavigationSearchDelegate> search_delegate;
@property(nonatomic, retain, setter = setInlineSearchView:) NavigationSearchInlineView* inline_search_view;
@property(nonatomic, retain, setter = setSearchView:) NavigationSearchView* search_view;
@property(atomic, setter = setFilterEnabled:) BOOL filter_enabled;
@property(nonatomic) UISearchBar* search_bar;
@property(nonatomic) BOOL hidesBarOnSwipe;

-(instancetype)init;
-(instancetype)initWithFilterEnabled:(BOOL)filter_enabled;

-(void)setSearchText:(NSString*)text endEditing:(BOOL)end_editing;
-(void)setSearchText:(NSString*)text endEditingAsFinal:(BOOL)end_editing;
@end
