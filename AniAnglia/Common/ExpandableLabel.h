//
//  ExpandableLabel.h
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#ifndef ExpandableLabel_h
#define ExpandableLabel_h

#import <UIKit/UIKit.h>

@class ExpandableLabel;

@protocol ExpandableLabelDelegate <NSObject>
-(void)didExpandPressedForExpandableLabel:(ExpandableLabel*)expandable_label;
@end

@interface ExpandableLabel : UIView
@property(nonatomic, weak) id<ExpandableLabelDelegate> delegate;

-(void)setText:(NSString*)text;
-(void)setNumberOfLines:(NSInteger)number_of_lines;
@end


#endif /* ExpandableLabel_h */
