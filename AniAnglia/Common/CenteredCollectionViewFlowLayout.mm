//
//  CenteredCollectionViewFlowLayout.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#import <Foundation/Foundation.h>
#import "CenteredCollectionViewFlowLayout.h"

@interface CenteredCollectionViewFlowLayout ()

@end

@implementation CenteredCollectionViewFlowLayout

/*
 https://stackoverflow.com/questions/47999130/how-to-center-horizontally-self-sizing-uicollectionview-cells/50931019
 TODO: vertical scroll
*/
-(NSArray<UICollectionViewLayoutAttributes*>*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes*>* attributes = [super layoutAttributesForElementsInRect:rect];
    if (!attributes) {
        return nil;
    }
    if (self.scrollDirection != UICollectionViewScrollDirectionHorizontal) {
        return attributes;
    }
    
    CGFloat rightmost_edge = 0;
    for (UICollectionViewLayoutAttributes* attribute : attributes) {
        rightmost_edge = MAX(rightmost_edge, CGRectGetMaxX(attribute.frame));
    }
    if (rightmost_edge == 0) {
        return attributes;
    }
    
    CGFloat content_width = rightmost_edge + self.sectionInset.right;
    CGFloat margin = (self.collectionView.bounds.size.width - content_width) / 2;
    if (margin <= 0) {
        return attributes;
    }
    
    NSMutableArray<UICollectionViewLayoutAttributes*>* new_attributes = [NSMutableArray arrayWithCapacity:[attributes count]];
    for (UICollectionViewLayoutAttributes* attribute : attributes) {
        UICollectionViewLayoutAttributes* new_attribute = [attribute copy];
        CGRect new_frame = new_attribute.frame;
        new_frame.origin.x += margin;
        new_attribute.frame = new_frame;
        
        [new_attributes addObject:new_attribute];
    }
    return new_attributes;
}

@end
