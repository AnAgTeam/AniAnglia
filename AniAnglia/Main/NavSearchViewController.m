//
//  NavigationAndSearchController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "NavSearchViewController.h"

@interface NavigationSearchViewController ()
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

-(instancetype)initWithNibName:(NSString *)nib_name_or_nil bundle:(NSBundle *)nib_bundle_or_nil {
    self = [super initWithNibName:nib_name_or_nil bundle:nib_bundle_or_nil];
    
    _filter_enabled = NO;
    _search_delegate = nil;
    [self setupSearchBar];
    
    return self;
}

/* called from storyboard */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
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

-(void)setupSearchBar {
    _search_bar = [UISearchBar new];
    _search_bar.delegate = self;
    self.navigationItem.titleView = _search_bar;
    self.navigationController.hidesBarsOnSwipe = YES;
    _search_cancel_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonPressed:)];
    if (_filter_enabled) {
        _search_filter_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarFilterButtonPressed:)];
    } else {
        _search_filter_bar_item = nil;
    }
}

-(void)cancelSearchBar {
    [_search_bar endEditing:YES];
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
    [self cancelSearchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)search_bar {
    if ([search_bar.text length] > 0 && _search_delegate) {
        [_search_delegate search:search_bar.text];
    }
}

-(IBAction)searchBarCancelButtonPressed:(id)sender {
    _search_bar.text = @"";
    [_search_bar endEditing:YES];
}
-(IBAction)searchBarFilterButtonPressed:(id)sender {
    if (_search_delegate) {
        [_search_delegate searchBarFilterButtonPressed];
    }
}
@end
