//
//  NavigationAndSearchController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "NavSearchViewController.h"

@interface NavigationSearchViewController ()
@property(nonatomic, retain) UISearchController* search_controller;
@property(nonatomic, retain) UIBarButtonItem* search_cancel_bar_item;
@property(nonatomic, retain) UIBarButtonItem* search_filter_bar_item;
@end

@implementation NavigationSearchViewController

-(instancetype)init {
    self = [super init];
    
    _filter_enabled = NO;
    _search_delegate = nil;
    [self setupSearchBar];
    
    return self;
}

-(instancetype)initWithDelegate:(id<NavigationSearchDelegate>)view_controller filterEnabled:(BOOL)filter_enabled {
    self = [super init];
    
    _filter_enabled = filter_enabled;
    _search_delegate = view_controller;
    [self setupSearchBar];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupSearchBar];
}

-(void)setupSearchBar {
    _search_controller = [UISearchController new];
    _search_controller.hidesNavigationBarDuringPresentation = NO;
    _search_controller.searchBar.showsCancelButton = NO;
    [_search_controller.searchBar setDelegate:self];
    self.navigationItem.titleView = _search_controller.searchBar;
    self.navigationController.hidesBarsOnSwipe = YES;
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
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)search_bar {
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationItem.leftBarButtonItem = _search_cancel_bar_item;
    self.navigationItem.rightBarButtonItem = _search_filter_bar_item;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)search_bar {
    self.navigationController.hidesBarsOnSwipe = YES;
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
