//
//  SearchViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.03.2025.
//

#import <Foundation/Foundation.h>
#import "SearchViewController.h"

@interface SearchViewController ()
@property(nonatomic, retain) UISearchBar* search_bar;
@property(nonatomic, retain) UIBarButtonItem* back_bar_button;
@property(nonatomic, retain) UIViewController* inline_view_controller;
@property(nonatomic, retain) NSString* initial_search_bar_text;

@property(nonatomic) UIBarButtonItem* orig_right_bar_button;

@end

@implementation SearchViewController

-(instancetype)initWithContentViewController:(UIViewController*)content_view_controller {
    self = [super init];
    
    _content_view_controller = content_view_controller;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
//    _content_view_controller.root_search_view_controller = self;
    _content_view_controller.additionalSafeAreaInsets = self.view.safeAreaInsets;
    
    _search_bar = [UISearchBar new];
    _search_bar.delegate = self;
    _search_bar.placeholder = _search_bar_placeholder;
    _search_bar.text = _initial_search_bar_text;
    _search_bar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _back_bar_button = [[UIBarButtonItem alloc] initWithPrimaryAction:[UIAction actionWithTitle:@"" image:[UIImage systemImageNamed:@"chevron.left"] identifier:nil handler:^(UIAction* action){
        [self onBackButtonPressed];
    }]];
    
    [self addChildViewController:_content_view_controller];
    self.navigationItem.titleView = _search_bar;
    [self.view addSubview:_content_view_controller.view];
    
    _content_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_view_controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_content_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_content_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_content_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_content_view_controller.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [_content_view_controller.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
    ]];
    
    [_content_view_controller didMoveToParentViewController:self];
}
-(void)setupLayout {
    
}

-(void)setBarButtonsHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = _orig_right_bar_button;
        return;
    }
    _orig_right_bar_button = self.navigationItem.rightBarButtonItem;
    [self.navigationItem setLeftBarButtonItem:_back_bar_button animated:YES];
    [self.navigationItem setRightBarButtonItem:_right_bar_button animated:YES];
}

-(void)showInlineSearchViewController:(UIViewController*)view_controller {
    if (!view_controller) {
        return;
    }
    _inline_view_controller = view_controller;
    [self addChildViewController:_inline_view_controller];
    [self.view addSubview:_inline_view_controller.view];
    
    _inline_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_inline_view_controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_inline_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_inline_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_inline_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    [_inline_view_controller didMoveToParentViewController:self];
}
-(void)hideInlineSearchViewController {
    if (!_inline_view_controller) {
        return;
    }
    [_inline_view_controller willMoveToParentViewController:nil];
    [_inline_view_controller.view removeFromSuperview];
    [_inline_view_controller removeFromParentViewController];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    [self setBarButtonsHidden:NO];
    
    _inline_view_controller = [_data_source inlineViewControllerForSearchViewController:self];
    [self showInlineSearchViewController:_inline_view_controller];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    [search_bar endEditing:YES];
    [self hideInlineSearchViewController];
    [self setBarButtonsHidden:YES];
    [_delegate searchViewController:self didSearchWithQuery:_search_bar.text];
}

-(IBAction)searchBarCancelButtonPressed:(UIBarButtonItem*)sender {
    _search_bar.text = @"";
    [_search_bar endEditing:YES];
    [self setBarButtonsHidden:YES];
    [self hideInlineSearchViewController];
}
-(void)onBackButtonPressed {
    _search_bar.text = @"";
    [_search_bar endEditing:YES];
    [self setBarButtonsHidden:YES];
    [self hideInlineSearchViewController];
}

-(void)setSearchText:(NSString*)text {
    if (!_search_bar) {
        _initial_search_bar_text = text;
        return;
    }
    _search_bar.text = text;
}

-(void)endSearching {
    [_search_bar endEditing:YES];
    [self setBarButtonsHidden:YES];
    [self hideInlineSearchViewController];
}

@end
