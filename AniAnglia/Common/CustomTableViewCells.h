//
//  CustomTableViewCells.h
//  AniAnglia
//
//  Created by Toilettrauma on 08.04.2025.
//

#ifndef CustomTableViewCells_h
#define CustomTableViewCells_h

#import <UIKit/UIKit.h>

@class TextFieldTableViewCell;

@protocol TextFieldTableViewCellDelegate <NSObject>
-(void)textFieldViewCellDidBeginEditing:(TextFieldTableViewCell*)text_field_cell;
-(void)textFieldViewCellDidEndEditing:(TextFieldTableViewCell*)text_field_cell;
-(BOOL)textFieldViewCellShouldReturn:(TextFieldTableViewCell*)text_field_cell;
@end

@interface TextFieldTableViewCell : UITableViewCell
@property(nonatomic, weak) id<TextFieldTableViewCellDelegate> delegate;

+(NSString*)getIdentifier;

-(void)setPlaceholder:(NSString*)placeholder;
-(void)setText:(NSString*)text;
-(NSString*)getText;

-(void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalization_type;
-(void)setAutocorrectionType:(UITextAutocorrectionType)autocorrection_type;
-(void)disableAutocapitalizationAndCorrection;

-(BOOL)isTextChanged;
@end

@interface TransitionTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setImage:(UIImage*)image tintColor:(UIColor*)tintColor color:(UIColor*)color;
-(void)setName:(NSString*)name;
-(void)setContent:(NSString*)content;
@end

@interface PlainTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setContent:(NSString*)content;
-(void)setContentColor:(UIColor*)color;
@end

@interface SwitchTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setContent:(NSString*)content;
-(void)setOn:(BOOL)on;
-(void)setHandler:(void(^)(BOOL is_on))handler;
@end

@interface MenuTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setTitle:(NSString*)title;
-(void)setContent:(NSString*)content;
-(void)setMenuActions:(NSArray<UIAction*>*)actions;
@end

#endif /* CustomTableViewCells_h */
