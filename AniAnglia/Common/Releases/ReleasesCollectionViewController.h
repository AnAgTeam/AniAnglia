//
//  ReleaseCollectionViewCell.h
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#ifndef ReleaseCollectionViewCell_h
#define ReleaseCollectionViewCell_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ReleaseCollectionViewCell : UICollectionViewCell

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)image_url;
-(void)setTitle:(NSString*)title;
-(void)setSetEpisodeCount:(NSString*)episode_count;
-(void)setRating:(double)rating;
@end

@interface ReleasesCollectionViewController : UIViewController
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages axis:(UICollectionViewScrollDirection)axis;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;

-(void)setHeaderView:(UIView*)header_view;

-(void)setAxisItemCount:(NSInteger)axis_item_count;
@end


#endif /* ReleaseCollectionViewCell_h */
