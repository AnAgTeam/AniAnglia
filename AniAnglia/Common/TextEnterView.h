//
//  TextEnterView.h
//  AniAnglia
//
//  Created by Toilettrauma on 14.04.2025.
//

#ifndef TextEnterView_h
#define TextEnterView_h

#import <UIKit/UIKit.h>

@class TextEnterView;

@protocol TextEnterViewDelegate <NSObject>
-(void)didSendPressedForTextEnterView:(TextEnterView*)text_enter_view;
@end

@interface TextEnterView : UIView
@property(nonatomic, weak) id<TextEnterViewDelegate> delegate;
@property(nonatomic, readonly) BOOL is_spoiler;
@property(nonatomic, readonly) BOOL is_custom_editing;

-(void)setText:(NSString*)text;
-(NSString*)getText;
-(void)setPlaceholder:(NSString*)placeholder;

-(void)endEditing:(BOOL)end_editing;
-(void)startEditing;

-(void)beginCustomTextEditing:(NSString*)original_text;
-(void)endCustomTextEditing;
@end

#endif /* TextEnterView_h */
