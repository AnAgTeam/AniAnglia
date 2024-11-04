//
//  NavigationAndSearchController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "NavigationAndSearchController.h"

@interface NavigationSearchController ()
@property(atomic) BOOL filter_enabled;;
@property(nonatomic, retain) UISearchController* search_controller;
@property(nonatomic, retain) UIBarButtonItem* search_cancel_bar_item;
@property(nonatomic, retain) UIBarButtonItem* search_filter_bar_item;
@end

@implementation NavigationSearchController : UINavigationController
-(instancetype)initWithDelegateRootViewController:(UIViewController<NavigationSearchDelegate>*)view_controller filterEnabled:(BOOL)filter_enabled {
    self = [super initWithRootViewController:view_controller];
    
    _filter_enabled = filter_enabled;
    _search_delegate = view_controller;
    [self setupSearchBar];
    
    return self;
}

//-(void)viewDidLoad {
//    [super viewDidLoad];
//    [self setupSearchBar];
//}

-(void)setupSearchBar {
    _search_controller = [UISearchController new];
    _search_controller.hidesNavigationBarDuringPresentation = NO;
    _search_controller.searchBar.showsCancelButton = NO;
    [_search_controller.searchBar setDelegate:self];
//    _search_delegate.navigationItem.titleView = _search_controller.searchBar;
//    self.hidesBarsOnSwipe = YES;
    _search_cancel_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonPressed:)];
    if (_filter_enabled) {
        _search_filter_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarFilterButtonPressed:)];
    } else {
        _search_filter_bar_item = nil;
    }
}

-(UISearchBar*)searchBar {
    return _search_controller.searchBar;
}

-(void)cancelSearchBar {
    [_search_controller.searchBar endEditing:YES];
    _search_delegate.navigationItem.leftBarButtonItem = nil;
    _search_delegate.navigationItem.rightBarButtonItem = nil;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)search_bar {
    self.hidesBarsOnSwipe = NO;
    _search_delegate.navigationItem.leftBarButtonItem = _search_cancel_bar_item;
    _search_delegate.navigationItem.rightBarButtonItem = _search_filter_bar_item;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)search_bar {
    self.hidesBarsOnSwipe = YES;
    if ([search_bar.text length] > 0) {
        [_search_delegate search:search_bar.text];
    }
    [self cancelSearchBar];
}

-(IBAction)searchBarCancelButtonPressed:(id)sender {
    _search_controller.searchBar.text = @"";
    [_search_controller.searchBar endEditing:YES];
}
-(IBAction)searchBarFilterButtonPressed:(id)sender {
    [_search_delegate searchBarFilterButtonPressed];
}
@end
