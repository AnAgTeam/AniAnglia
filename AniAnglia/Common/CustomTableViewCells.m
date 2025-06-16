//
//  CustomTableViewCells.m
//  AniAnglia
//
//  Created by Toilettrauma on 08.04.2025.
//

#import <Foundation/Foundation.h>
#import "CustomTableViewCells.h"
#import "AppColor.h"

@interface TextFieldTableViewCell () <UITextFieldDelegate>
@property(nonatomic, retain) UITextField* text_field;
@property(nonatomic, retain) NSString* orig_text;
@end

@interface TransitionTableViewCell ()
@property(nonatomic, retain) UIImageView* image_view;
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UILabel* content_label;
@property(nonatomic, retain) UIImageView* arrow_image_view;
@property(nonatomic, retain) NSLayoutConstraint* image_view_width_constraint;
@end

@interface PlainTableViewCell ()
@property(nonatomic, retain) UILabel* content_label;
@end

@interface SwitchTableViewCell ()
@property(nonatomic, retain) UILabel* content_label;
@property(nonatomic, retain) UISwitch* switch_view;
@property(nonatomic, copy) void(^handler)(BOOL is_on);

@end

@interface MenuTableViewCell ()
@property(nonatomic, retain) UIButton* button;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* content_label;
@property(nonatomic, retain) UIImageView* image_view;
@property(nonatomic, retain) UIMenu* menu;
@end

@implementation TextFieldTableViewCell

+(NSString*)getIdentifier {
    return @"TextFieldTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _text_field = [UITextField new];
    _text_field.delegate = self;
    
    [self.contentView addSubview:_text_field];
    
    _text_field.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_text_field.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_text_field.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_text_field.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_text_field.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _text_field.textColor = [AppColorProvider textColor];
}

-(void)setPlaceholder:(NSString*)placeholder {
    _text_field.placeholder = placeholder;
}
-(void)setText:(NSString*)text {
    _orig_text = _text_field.text = text;
}
-(NSString*)getText {
    return _text_field.text;
}

-(void)textFieldDidBeginEditing:(UITextField*)text_field {
    [_delegate textFieldViewCellDidBeginEditing:self];
}
-(void)textFieldDidEndEditing:(UITextField *)text_field {
    [_delegate textFieldViewCellDidEndEditing:self];
}
-(BOOL)textFieldShouldReturn:(UITextField*)text_field {
    return [_delegate textFieldViewCellShouldReturn:self];
}

-(void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalization_type {
    _text_field.autocapitalizationType = autocapitalization_type;
}
-(void)setAutocorrectionType:(UITextAutocorrectionType)autocorrection_type {
    _text_field.autocorrectionType = autocorrection_type;
}
-(void)disableAutocapitalizationAndCorrection {
    _text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _text_field.autocorrectionType = UITextAutocorrectionTypeNo;
}

-(BOOL)isTextChanged {
    return ![_orig_text isEqualToString:_text_field.text];
}
@end

@implementation TransitionTableViewCell

+(NSString*)getIdentifier {
    return @"TransitionTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [UIImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    _image_view.contentMode = UIViewContentModeCenter;
    
    _name_label = [UILabel new];
    _content_label = [UILabel new];
    _arrow_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    
    [self addSubview:_image_view];
    [self addSubview:_name_label];
    [self addSubview:_content_label];
    [self addSubview:_arrow_image_view];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    _arrow_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _image_view_width_constraint = [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        _image_view_width_constraint,
        
        [_name_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:10],
        [_name_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_content_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_name_label.trailingAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_arrow_image_view.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_arrow_image_view.leadingAnchor constraintGreaterThanOrEqualToAnchor:_content_label.trailingAnchor],
        [_arrow_image_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_arrow_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.7],
        [_arrow_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_arrow_image_view.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _name_label.textColor = [AppColorProvider textColor];
    _content_label.textColor = [AppColorProvider textSecondaryColor];
    _arrow_image_view.tintColor = [AppColorProvider textSecondaryColor];
}

-(void)setImage:(UIImage*)image tintColor:(UIColor*)tintColor color:(UIColor*)color {
    _image_view_width_constraint.active = image != nil;
    _image_view.image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    _image_view.tintColor = [tintColor colorWithAlphaComponent:0.9];
    _image_view.backgroundColor = color;
}
-(void)setName:(NSString*)name {
    _name_label.text = name;
}
-(void)setContent:(NSString*)content {
    _content_label.text = content;
}
@end

@implementation PlainTableViewCell

+(NSString*)getIdentifier {
    return @"PlainTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _content_label = [UILabel new];
    
    [self addSubview:_content_label];
    
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_content_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_content_label.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _content_label.textColor = [AppColorProvider textColor];
}

-(void)setContent:(NSString*)content {
    _content_label.text = content;
}
-(void)setContentColor:(UIColor*)color {
    _content_label.textColor = color;
}
@end

@implementation SwitchTableViewCell

+(NSString*)getIdentifier {
    return @"SwitchTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _content_label = [UILabel new];
    _switch_view = [UISwitch new];
    [_switch_view addTarget:self action:@selector(onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addSubview:_content_label];
    [self.contentView addSubview:_switch_view];
    
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    _switch_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_switch_view.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_switch_view.leadingAnchor constraintGreaterThanOrEqualToAnchor:_content_label.trailingAnchor constant:8],
        [_switch_view.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_switch_view.heightAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor],
        [_switch_view.widthAnchor constraintEqualToConstant:51],
        [_switch_view.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_switch_view.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _content_label.textColor = [AppColorProvider textColor];
}

-(void)setContent:(NSString*)content {
    _content_label.text = content;
}
-(void)setOn:(BOOL)on {
    _switch_view.on = on;
}
-(void)setHandler:(void(^)(BOOL is_on))handler {
    _handler = handler;
}

-(IBAction)onSwitchValueChanged:(UISwitch*)sender {
    _handler(_switch_view.isOn);
}
@end

@implementation MenuTableViewCell

+(NSString*)getIdentifier {
    return @"MenuTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _button = [UIButton new];
    _button.showsMenuAsPrimaryAction = YES;
    
    _title_label = [UILabel new];
    _title_label.textAlignment = NSTextAlignmentLeft;
    
    _content_label = [UILabel new];
    _content_label.textAlignment = NSTextAlignmentRight;
    
    _image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.down"]];
    
    
    [self.contentView addSubview:_button];
    [self.contentView addSubview:_title_label];
    [self.contentView addSubview:_content_label];
    [self.contentView addSubview:_image_view];
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_button.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_button.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_button.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_button.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_title_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_content_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_title_label.trailingAnchor constant:5],
        [_content_label.trailingAnchor constraintEqualToAnchor:_image_view.leadingAnchor constant:-2],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_image_view.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_image_view.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_image_view.heightAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor multiplier:0.7],
        [_image_view.widthAnchor constraintEqualToConstant:15],
        [_image_view.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_image_view.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _content_label.textColor = [AppColorProvider textSecondaryColor];
    _image_view.tintColor = [AppColorProvider textShyColor];
}

-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setContent:(NSString*)content {
    _content_label.text = content;
}
-(void)setMenuActions:(NSArray<UIAction*>*)actions {
    _menu = [UIMenu menuWithTitle:@"" children:actions];
    [_button setMenu:_menu];
}
@end
