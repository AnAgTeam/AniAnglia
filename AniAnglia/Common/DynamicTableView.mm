//
//  DynamicTableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#import <Foundation/Foundation.h>
#import "DynamicTableView.h"

@interface DynamicTableView ()
@property(nonatomic, retain) NSLayoutConstraint* my_height_constraint;
@end

@implementation DynamicTableView

-(void)setContentSize:(CGSize)content_size {
    [super setContentSize:content_size];
    if (!_my_height_constraint) {
        _my_height_constraint = [self.heightAnchor constraintEqualToConstant:content_size.height];
        _my_height_constraint.active = YES;
    } else {
        _my_height_constraint.constant = content_size.height;
    }
    [self invalidateIntrinsicContentSize];
}
-(CGSize)contentSize {
//    [self layoutIfNeeded];
    return [super contentSize];
}
-(void)reloadData {
    [super reloadData];
//    [self invalidateIntrinsicContentSize];
}

@end
