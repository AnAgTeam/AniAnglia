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
#import "ReleasesPageableDataProvider.h"

@interface ReleaseCollectionViewCell : UICollectionViewCell

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)image_url;
-(void)setTitle:(NSString*)title;
-(void)setSetEpisodeCount:(NSString*)episode_count;
-(void)setRating:(double)rating;
-(void)setListStatus:(anixart::Profile::ListStatus)list_status;
@end

// Always automatically sets delegate for "PageableDataProviderDelegate"
@interface ReleasesCollectionViewController : UIViewController <PageableDataProviderDelegate>
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithAxis:(UICollectionViewScrollDirection)axis;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages axis:(UICollectionViewScrollDirection)axis;
-(instancetype)initWithReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider axis:(UICollectionViewScrollDirection)axis;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)setReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider;

-(void)reload;
-(void)refresh;

-(void)reloadData;

-(void)setHeaderView:(UIView*)header_view;

// Vertical not supported
-(void)setAxisItemCount:(NSInteger)axis_item_count;
@end


#endif /* ReleaseCollectionViewCell_h */
