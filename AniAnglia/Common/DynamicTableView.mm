//
//  DynamicTableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#import <Foundation/Foundation.h>
#import "DynamicTableView.h"

@interface DynamicTableView ()

@end

@implementation DynamicTableView

-(void)setContentSize:(CGSize)content_size {
    [super setContentSize:content_size];
    [self invalidateIntrinsicContentSize];
}

-(void)reloadData {
    [super reloadData];
    [self invalidateIntrinsicContentSize];
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(self.contentSize.width, self.contentSize.height);
}

@end
