//
//  AppSearchBarController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "AppSearchController.h"
#import "AppColor.h"

@interface AppSearchBar () <UISearchBarDelegate> {
    NSLayoutConstraint* _text_field_leading;
    NSLayoutConstraint* _text_field_trailing;
}

@end

@implementation AppSearchBar

@synthesize delegate = _proxy_delegate;

-(instancetype)init {
    self = [super init];
    [self setupView];

//    [super setDelegate:self];
    self.showsCancelButton = NO;
    return self;
}

-(void)setupView {
    _cancel_button = [UIButton new];
    [self addSubview:_cancel_button];
    [_cancel_button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_cancel_button.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_cancel_button.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_cancel_button.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_cancel_button setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    _cancel_button.hidden = YES;
    
    _filter_button = [UIButton new];
    [self addSubview:_filter_button];
    [_filter_button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_filter_button.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_filter_button.heightAnchor constraintEqualToConstant:20].active = YES;
    [_filter_button.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_filter_button setImage:[UIImage systemImageNamed:@"slider.horizontal.3"] forState:UIControlStateNormal];
    _filter_button.hidden = YES;
    
//    self.searchTextField.translatesAutoresizingMaskIntoConstraints = NO;
//    _text_field_leading = [self.searchTextField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
//    _text_field_leading.active = YES;
//    _text_field_trailing = [self.searchTextField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor];
//    _text_field_trailing.active = YES;
//    [self.searchTextField.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
//    [self.searchTextField.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.5].active = YES;
}
-(id<UISearchBarDelegate>)delegate {
    return _proxy_delegate;

}
-(void)setDelegate:(id<UISearchBarDelegate>)delegate {
    _proxy_delegate = delegate;
}

-(void)showEditingButtons {
    _cancel_button.hidden = NO;
    [self.searchTextField.leadingAnchor constraintEqualToAnchor:_cancel_button.trailingAnchor].active = YES;
    _filter_button.hidden = NO;
    [self.searchTextField.trailingAnchor constraintEqualToAnchor:_filter_button.leadingAnchor].active = YES;
}
-(void)hideEditingButtons {
    _filter_button.hidden = YES;
    _cancel_button.hidden = YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)search_bar {
    [self showEditingButtons];
    [_proxy_delegate searchBarTextDidBeginEditing:search_bar];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)search_bar {
    [self hideEditingButtons];
    [_proxy_delegate searchBarTextDidEndEditing:search_bar];
}
@end

@implementation AppSearchController

-(instancetype)initWithPlaceholder:(NSString*)placeholder {
    self = [super init];
    
    [self setupView];
    _search_bar.placeholder = placeholder;
    
    return self;
}

-(void)setupView {
    _search_bar = [AppSearchBar new];
}

-(void)setupLayout {
    
}

-(UISearchBar*)searchBar {
    return _search_bar;
}

@end
