//
//  ExpandableLabel.m
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#import <Foundation/Foundation.h>
#import "ExpandableLabel.h"
#import "AppColor.h"

@interface ExpandableLabel ()
@property(nonatomic, retain) UILabel* text_label;
@property(nonatomic, retain) UIButton* show_all_button;
@property(nonatomic) NSInteger number_of_lines;
@property(nonatomic) BOOL show_all_button_pressed;

@end

@implementation ExpandableLabel

-(instancetype)init {
    self = [super init];
    
    _number_of_lines = 5;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _text_label = [UILabel new];
    _text_label.numberOfLines = _number_of_lines;
    _text_label.textAlignment = NSTextAlignmentJustified;
    
    _show_all_button = [UIButton new];
    [_show_all_button setTitle:NSLocalizedString(@"app.common.expandable_label.show_all.title", "") forState:UIControlStateNormal];
    [_show_all_button addTarget:self action:@selector(onShowAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_text_label];
    
    _text_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_text_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_text_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_text_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_text_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    _text_label.textColor = [AppColorProvider textColor];
    [_show_all_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self addShowAllButtonIfNeeded];
}

-(void)setText:(NSString*)text {
    _text_label.text = text;
    _show_all_button_pressed = NO;
}
-(void)setNumberOfLines:(NSInteger)number_of_lines {
    _number_of_lines = number_of_lines;
    _text_label.numberOfLines = number_of_lines;
    _show_all_button_pressed = NO;
}

-(void)addShowAllButtonIfNeeded {
    if (_show_all_button_pressed || [_text_label.text length] == 0) {
        return;
    }
    
    CGSize text_size = [_text_label.text boundingRectWithSize:CGSizeMake(_text_label.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _text_label.font} context:nil].size;
    
    if (text_size.height > _text_label.bounds.size.height) {
        [self addSubview:_show_all_button];
        
        _show_all_button.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_show_all_button.topAnchor constraintEqualToAnchor:_text_label.bottomAnchor constant:5],
            [_show_all_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [_show_all_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
            [_show_all_button.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
            [_show_all_button.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
        ]];
    }
}

-(IBAction)onShowAllButtonPressed:(UIButton*)sender {
    _show_all_button_pressed = YES;
    _text_label.numberOfLines = 0;
    [_text_label sizeToFit];
    [_show_all_button removeFromSuperview];
    [_delegate didExpandPressedForExpandableLabel:self];
}

@end
