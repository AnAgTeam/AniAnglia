//
//  NavigationAndSearchController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "NavSearchViewController.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface NavigationSearchViewController () {
    struct {
        BOOL search_method;
        BOOL filter_method;
    } _delegate_responds_to;
}
@property(nonatomic, retain) UIBarButtonItem* search_cancel_bar_item;
@property(nonatomic, retain) UIBarButtonItem* search_filter_bar_item;
@property(nonatomic, retain) NSArray<NSLayoutConstraint*>* inline_search_view_constraints;
@property(nonatomic, retain) NSArray<NSLayoutConstraint*>* search_view_constraints;
@end

@implementation NavigationSearchInlineView
-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller {
    
}
-(void)searchTextDidChanged:(NSString*)text {
    
}
-(void)searchViewDidCancelWithText:(NSString*)text isSearchQuery:(BOOL)is_search_query {
    
}
@end
@implementation NavigationSearchView
-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller {
    
}
-(void)reloadWithText:(NSString*)text {
    
}
@end

@implementation NavigationSearchViewController

-(void)setDefaults {
    _inline_search_view = nil;
    _search_view = nil;
    _search_delegate = nil;
    _delegate_responds_to.search_method = NO;
    _delegate_responds_to.filter_method = NO;
}

-(instancetype)init {
    self = [super init];
    
    _hidesBarOnSwipe = YES;
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

-(instancetype)initWithNibName:(NSString *)nib_name_or_nil bundle:(NSBundle *)nib_bundle_or_nil {
    self = [super initWithNibName:nib_name_or_nil bundle:nib_bundle_or_nil];
    
    _hidesBarOnSwipe = YES;
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

/* called from storyboard */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    _hidesBarOnSwipe = YES;
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setSearchDelegate:(id<NavigationSearchDelegate>)search_delegate {
    _search_delegate = search_delegate;
    NSObject<NavigationSearchDelegate>* delegate = (NSObject<NavigationSearchDelegate>*)search_delegate;
    _delegate_responds_to.search_method = [delegate respondsToSelector:@selector(search:)];
    _delegate_responds_to.filter_method = [delegate respondsToSelector:@selector(searchBarFilterButtonPressed)];
}

-(void)setupSearchViews {
    _search_bar = [UISearchBar new];
    _search_bar.delegate = self;
    self.navigationItem.titleView = _search_bar;
    self.navigationController.hidesBarsOnSwipe = _hidesBarOnSwipe;
    _search_cancel_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonPressed:)];
    _search_filter_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarFilterButtonPressed:)];
}

-(void)showInlineSearchView {
    if (_inline_search_view) {
        [self.view addSubview:_inline_search_view];
        [NSLayoutConstraint activateConstraints:_inline_search_view_constraints];
        [_inline_search_view searchViewDidShowWithController:self];
    }
}
-(void)hideInlineSearchView {
    [NSLayoutConstraint deactivateConstraints:_inline_search_view_constraints];
    [_inline_search_view removeFromSuperview];
}
-(void)showSearchView {
    if (_search_view.superview) {
        [self hideInlineSearchView];
    }
    if (_search_view) {
        [self.view addSubview:_search_view];
        [NSLayoutConstraint activateConstraints:_search_view_constraints];
        [_search_view searchViewDidShowWithController:self query:_search_bar.text];
    }
}
-(void)hideSearchView {
    [NSLayoutConstraint deactivateConstraints:_search_view_constraints];
    [_search_view removeFromSuperview];
}
-(void)showSearchButtons {
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationItem.leftBarButtonItem = _search_cancel_bar_item;
    if (_filter_enabled) {
        self.navigationItem.rightBarButtonItem = _search_filter_bar_item;
    }
}
-(void)hideSearchButtons {
    self.navigationController.hidesBarsOnSwipe = _hidesBarOnSwipe;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)setInlineSearchView:(NavigationSearchInlineView *)inline_search_view {
    _inline_search_view = inline_search_view;
    _inline_search_view.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 15.0, *)) {
        _inline_search_view_constraints = @[
            [_inline_search_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_inline_search_view.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor],
            [_inline_search_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_inline_search_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
        ];
    } else {
        _inline_search_view_constraints = @[
            [_inline_search_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_inline_search_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            [_inline_search_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_inline_search_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
        ];
    }
}
-(void)setSearchView:(NavigationSearchView *)search_view {
    _search_view = search_view;
    _search_view.translatesAutoresizingMaskIntoConstraints = NO;
    _search_view_constraints = @[
        [_search_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_search_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_search_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_search_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
     ];
}

-(void)setSearchText:(NSString*)text endEditing:(BOOL)end_editing {
    _search_bar.text = text;
    [_search_bar endEditing:end_editing];
}
-(void)setSearchText:(NSString*)text endEditingAsFinal:(BOOL)end_editing {
    _search_bar.text = text;
    if (end_editing) {
        [_search_bar endEditing:end_editing];
        [_inline_search_view searchViewDidCancelWithText:_search_bar.text isSearchQuery:YES];
        if (_delegate_responds_to.search_method) {
            [_search_delegate search:text];
        }
        [self showSearchView];
    }
}

-(void)searchBar:(UISearchBar *)search_bar textDidChange:(NSString *)search_text {
    [_inline_search_view searchTextDidChanged:search_text];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    [self showSearchButtons];
    
    if (_inline_search_view) {
        [self showInlineSearchView];
    }
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    
    if (_inline_search_view) {
        [self hideInlineSearchView];
        [_inline_search_view searchViewDidCancelWithText:_search_bar.text isSearchQuery:NO];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    if ([search_bar.text length] > 0) {
        [search_bar endEditing:YES];
        if (_inline_search_view) {
            [_inline_search_view searchViewDidCancelWithText:_search_bar.text isSearchQuery:YES];
        }
        [self hideSearchButtons];
        if (_delegate_responds_to.search_method) {
            [_search_delegate search:search_bar.text];
        }
        if (_search_view) {
            [self showSearchView];
            [self showSearchButtons];
        }
    }
}

-(IBAction)searchBarCancelButtonPressed:(id)sender {
    _search_bar.text = @"";
    [_search_bar endEditing:YES];
    [self hideSearchButtons];
    
    if (_search_view && _search_view.superview) {
        [self hideSearchView];
    }
}
-(IBAction)searchBarFilterButtonPressed:(id)sender {
    if (_delegate_responds_to.filter_method) {
        [_search_delegate searchBarFilterButtonPressed];
    }
}
@end
