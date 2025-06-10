//
//  NamedSectionView.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#import <Foundation/Foundation.h>
#import "NamedSectionView.h"
#import "AppColor.h"

@interface NamedSectionView ()
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIButton* show_all_button;
// maybe change to weak
@property(nonatomic, retain) UIView* view;
@property(nonatomic, copy) void(^show_all_handler)(void);

@end

@implementation NamedSectionView

-(instancetype)initWithName:(NSString*)name view:(UIView*)view {
    self = [super init];
    
    _name = name;
    _view = view;

    [self setup];
    [self setupLayout];
    
    return self;
}
-(instancetype)initWithName:(NSString*)name viewController:(UIViewController*)view_controller {
    return [self initWithName:name view:view_controller.view];
}

-(void)setup {
    _name_label = [UILabel new];
    _name_label.text = _name;
    _name_label.font = [UIFont systemFontOfSize:22];
    
    _show_all_button = [UIButton new];
    [_show_all_button setTitle:NSLocalizedString(@"app.common.named_section.show_all", "") forState:UIControlStateNormal];
    [_show_all_button addTarget:self action:@selector(onShowAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_name_label];
    [self addSubview:_show_all_button];
    [self addSubview:_view];
    
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _show_all_button.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_name_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor constant:8],
        [_name_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_name_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_show_all_button.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_show_all_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:_name_label.trailingAnchor constant:5],
        [_show_all_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor constant:-8],
        [_show_all_button.bottomAnchor constraintEqualToAnchor:_name_label.bottomAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_name_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    
    _show_all_button.hidden = YES;
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
    [_show_all_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
}

-(void)setupShowAllButtonLayout {
    
}

-(void)setShowAllButtonEnabled:(BOOL)enabled {
    _show_all_button.hidden = !enabled;
}

-(void)setShowAllHandler:(void(^)(void))handler {
    _show_all_handler = handler;
}

-(IBAction)onShowAllButtonPressed:(UIButton*)sender {
    if (_show_all_handler) {
        _show_all_handler();
    }
}

@end
