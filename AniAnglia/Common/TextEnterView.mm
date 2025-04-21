//
//  TextEnterView.m
//  AniAnglia
//
//  Created by Toilettrauma on 14.04.2025.
//

#import <Foundation/Foundation.h>
#import "TextEnterView.h"
#import "AppColor.h"

@class TextEnterCustomEditingHeaderView;

@protocol TextEnterCustomEditingHeaderViewDelegate <NSObject>
-(void)didExitPressedForTextEnterCustomEditingHeaderView:(TextEnterCustomEditingHeaderView*)text_enter_custom_editing_view;
@end

@interface TextEnterCustomEditingHeaderView : UIView
@property(nonatomic, weak) id<TextEnterCustomEditingHeaderViewDelegate> delegate;
@property(nonatomic, retain) NSString* original_text;
@property(nonatomic, retain) UIImageView* pencil_image_view;
@property(nonatomic, retain) UILabel* edit_text_label;
@property(nonatomic, retain) UILabel* original_text_label;
@property(nonatomic, retain) UIButton* exit_button;

-(instancetype)initWithOriginalText:(NSString*)original_text;
@end

@interface TextEnterView () <UITextViewDelegate, TextEnterCustomEditingHeaderViewDelegate>
@property(nonatomic, retain) NSString* placeholder;
@property(nonatomic, retain) UIView* inner_view;
@property(nonatomic, retain) UITextView* text_view;
@property(nonatomic, retain) UIButton* spoiler_button;
@property(nonatomic, retain) UIButton* send_button;
@property(nonatomic, retain) UILabel* placeholder_label;
@property(nonatomic, retain) NSLayoutConstraint* text_view_height_constraint;
@property(nonatomic, retain) TextEnterCustomEditingHeaderView* custom_editing_header;
@property(nonatomic, retain) NSArray<NSLayoutConstraint*>* custom_editing_header_bind_constraints;

@end

@implementation TextEnterCustomEditingHeaderView

-(instancetype)initWithOriginalText:(NSString*)original_text {
    self = [super init];
    
    _original_text = original_text;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _pencil_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"pencil"]];
    
    _edit_text_label = [UILabel new];
    _edit_text_label.text = NSLocalizedString(@"app.common.text_enter.edit_text", "");
    _edit_text_label.font = [UIFont systemFontOfSize:15];
    
    _original_text_label = [UILabel new];
    _original_text_label.numberOfLines = 1;
    _original_text_label.text = _original_text;
    _original_text_label.font = [UIFont systemFontOfSize:15];
    
    _exit_button = [UIButton new];
    [_exit_button setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    [_exit_button addTarget:self action:@selector(onExitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_pencil_image_view];
    [self addSubview:_edit_text_label];
    [self addSubview:_original_text_label];
    [self addSubview:_exit_button];
    
    _pencil_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _edit_text_label.translatesAutoresizingMaskIntoConstraints = NO;
    _original_text_label.translatesAutoresizingMaskIntoConstraints = NO;
    _exit_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_pencil_image_view.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_pencil_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_pencil_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.7],
        [_pencil_image_view.widthAnchor constraintEqualToAnchor:_pencil_image_view.heightAnchor],
        [_pencil_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_pencil_image_view.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_edit_text_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_edit_text_label.leadingAnchor constraintEqualToAnchor:_pencil_image_view.trailingAnchor constant:10],
        
        [_original_text_label.topAnchor constraintEqualToAnchor:_edit_text_label.bottomAnchor constant:5],
        [_original_text_label.leadingAnchor constraintEqualToAnchor:_edit_text_label.leadingAnchor],
        [_original_text_label.trailingAnchor constraintEqualToAnchor:_edit_text_label.trailingAnchor],
        [_original_text_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_exit_button.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_exit_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:_edit_text_label.trailingAnchor constant:10],
        [_exit_button.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_exit_button.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _pencil_image_view.tintColor = [AppColorProvider primaryColor];
    _edit_text_label.textColor = [AppColorProvider primaryColor];
    _original_text_label.textColor = [AppColorProvider textColor];
    _exit_button.tintColor = [AppColorProvider primaryColor];
}

-(IBAction)onExitButtonPressed:(UIButton*)sender {
    [_delegate didExitPressedForTextEnterCustomEditingHeaderView:self];
}

@end

@implementation TextEnterView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _inner_view = [UIView new];
    _inner_view.clipsToBounds = YES;
    _inner_view.layer.cornerRadius = 8;
    _inner_view.layoutMargins = UIEdgeInsetsMake(5, 5, 5, 5);
    
    _text_view = [UITextView new];
    _text_view.delegate = self;
    _text_view.font = [UIFont systemFontOfSize:16];
//    CGSize text_view_one_line_size = [@" " boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _text_view.font} context:nil].size;
    
    _placeholder_label = [UILabel new];
    _placeholder_label.text = _placeholder;
    
    _spoiler_button = [UIButton new];
    [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    [_spoiler_button addTarget:self action:@selector(onSpoilerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _spoiler_button.contentMode = UIViewContentModeScaleToFill;
    
    _send_button = [UIButton new];
    [_send_button setImage:[UIImage systemImageNamed:@"arrow.up"] forState:UIControlStateNormal];
    [_send_button addTarget:self action:@selector(onSendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _send_button.contentMode = UIViewContentModeScaleToFill;
    _send_button.layer.cornerRadius = 35 / 2;
    
    [self addSubview:_inner_view];
    [_inner_view addSubview:_text_view];
    [_inner_view addSubview:_spoiler_button];
    [_text_view addSubview:_placeholder_label];
    [self addSubview:_send_button];
    
    _inner_view.translatesAutoresizingMaskIntoConstraints = NO;
    _text_view.translatesAutoresizingMaskIntoConstraints = NO;
    _spoiler_button.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholder_label.translatesAutoresizingMaskIntoConstraints = NO;
    _send_button.translatesAutoresizingMaskIntoConstraints = NO;
    
    // TODO: autolayout instead of constants
    _text_view_height_constraint = [_text_view.heightAnchor constraintEqualToConstant:35];
    NSLayoutConstraint* inner_view_top_constraint = [_inner_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor];
    _custom_editing_header_bind_constraints = @[
        inner_view_top_constraint
    ];
    [NSLayoutConstraint activateConstraints:@[
        inner_view_top_constraint,
        [_inner_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_inner_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_text_view.topAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_text_view.leadingAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.leadingAnchor],
        _text_view_height_constraint,
        [_text_view.bottomAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.bottomAnchor],
        
        [_placeholder_label.topAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.topAnchor],
        [_placeholder_label.leadingAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.leadingAnchor],
        [_placeholder_label.trailingAnchor constraintEqualToAnchor:_text_view.layoutMarginsGuide.trailingAnchor],
        [_placeholder_label.bottomAnchor constraintLessThanOrEqualToAnchor:_text_view.layoutMarginsGuide.bottomAnchor],
        
        [_spoiler_button.topAnchor constraintGreaterThanOrEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_spoiler_button.leadingAnchor constraintEqualToAnchor:_text_view.trailingAnchor constant:5],
        [_spoiler_button.trailingAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.trailingAnchor],
//        [_spoiler_button.widthAnchor constraintEqualToConstant:50],
        [_spoiler_button.heightAnchor constraintEqualToConstant:33],
        [_spoiler_button.bottomAnchor constraintEqualToAnchor:_inner_view.bottomAnchor],
        
        [_send_button.topAnchor constraintGreaterThanOrEqualToAnchor:_inner_view.layoutMarginsGuide.topAnchor],
        [_send_button.leadingAnchor constraintEqualToAnchor:_inner_view.trailingAnchor constant:5],
        [_send_button.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_send_button.widthAnchor constraintEqualToConstant:35],
        [_send_button.heightAnchor constraintEqualToConstant:35],
//        [_send_button.centerYAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.centerYAnchor],
        [_send_button.bottomAnchor constraintEqualToAnchor:_inner_view.layoutMarginsGuide.bottomAnchor],
    ]];
    [_text_view sizeToFit];
    [_text_view layoutSubviews];
    [_inner_view layoutSubviews];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _inner_view.backgroundColor = [AppColorProvider backgroundColor];
    _spoiler_button.tintColor = [AppColorProvider textSecondaryColor];
    _placeholder_label.textColor = [AppColorProvider textShyColor];
    _send_button.backgroundColor = [AppColorProvider primaryColor];
    _send_button.tintColor = [AppColorProvider textColor];
}
-(void)updateSpoilerState {
    if (_is_spoiler) {
        [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
        _spoiler_button.tintColor = [AppColorProvider primaryColor];
    } else {
        [_spoiler_button setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
        _spoiler_button.tintColor = [AppColorProvider textSecondaryColor];
    }
}
-(void)updateTextViewHeight {
    [_text_view layoutIfNeeded];
    _text_view_height_constraint.constant = MAX(MIN(_text_view.contentSize.height, 300), 35);
}

-(void)setText:(NSString*)text {
    _text_view.text = text;
    [self updateTextViewHeight];
    _placeholder_label.hidden = [_text_view.text length] != 0;
}
-(NSString*)getText {
    return _text_view.text;
}
-(void)setPlaceholder:(NSString*)placeholder {
    _placeholder = placeholder;
    if (_placeholder_label) {
        _placeholder_label.text = placeholder;
    }
}
-(void)endEditing:(BOOL)end_editing {
    [_text_view endEditing:end_editing];
}
-(void)startEditing {
    [_text_view becomeFirstResponder];
}

-(void)beginCustomTextEditing:(NSString*)original_text {
    _is_custom_editing = YES;
    _custom_editing_header = [[TextEnterCustomEditingHeaderView alloc] initWithOriginalText:original_text];
    _custom_editing_header.layoutMargins = UIEdgeInsetsMake(3, 8, 3, 8);
    _custom_editing_header.delegate = self;
    
    [self setText:original_text];
    [self startEditing];
    
    [self addSubview:_custom_editing_header];
    
    _custom_editing_header.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint deactivateConstraints:_custom_editing_header_bind_constraints];
    _custom_editing_header_bind_constraints = @[
        [_custom_editing_header.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_custom_editing_header.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_custom_editing_header.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_inner_view.topAnchor constraintEqualToAnchor:_custom_editing_header.bottomAnchor constant:5],
    ];
    [NSLayoutConstraint activateConstraints:_custom_editing_header_bind_constraints];
}
-(void)endCustomTextEditing {
    _is_custom_editing = NO;
    
    [self setText:nil];
    [self endEditing:YES];
    
    [_custom_editing_header removeFromSuperview];
    
    [NSLayoutConstraint deactivateConstraints:_custom_editing_header_bind_constraints];
    _custom_editing_header_bind_constraints = @[
        [_inner_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
    ];
    [NSLayoutConstraint activateConstraints:_custom_editing_header_bind_constraints];
}

-(void)textViewDidChange:(UITextView*)text_view {
    [self updateTextViewHeight];
    _placeholder_label.hidden = [_text_view.text length] != 0;
}
-(IBAction)onSpoilerButtonPressed:(UIButton*)sender {
    _is_spoiler = !_is_spoiler;
    [self updateSpoilerState];
}
-(IBAction)onSendButtonPressed:(UIButton*)sender {
    [_delegate didSendPressedForTextEnterView:self];
    [self endCustomTextEditing];
}

-(void)didExitPressedForTextEnterCustomEditingHeaderView:(TextEnterCustomEditingHeaderView *)text_enter_custom_editing_view {
    [self endCustomTextEditing];
}

@end
