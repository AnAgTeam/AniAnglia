//
//  SearchViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.03.2025.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface UIViewController ()
@property(nonatomic, weak) SearchViewController* root_search_view_controller;
@end

@protocol SearchViewControllerDataSource <NSObject>

-(UIViewController*)inlineViewControllerForSearchViewController:(SearchViewController*)search_view_controller;

@end

@protocol SearchViewControllerDelegate <NSObject>

-(void)searchViewController:(SearchViewController*)search_view_controller didSearchWithQuery:(NSString*)query;

@end

@interface SearchViewController : UIViewController <UISearchBarDelegate>
@property(nonatomic, weak) id<SearchViewControllerDataSource> data_source;
@property(nonatomic, weak) id<SearchViewControllerDelegate> delegate;
@property(nonatomic, retain, readonly) UIViewController* content_view_controller;
@property(nonatomic, retain) UIBarButtonItem* right_bar_button;
@property(nonatomic, retain) NSString* search_bar_placeholder;

-(instancetype)initWithContentViewController:(UIViewController*)content_view_controller;

-(void)setSearchText:(NSString*)text;
-(void)endSearching;
@end
