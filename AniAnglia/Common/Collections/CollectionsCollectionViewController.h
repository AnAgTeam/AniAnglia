//
//  CollectionsTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#ifndef CollectionsTableViewController_h
#define CollectionsTableViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"
#import "CollectionsPageableDataProvider.h"

@interface CollectionCollectionViewCell : UICollectionViewCell

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)image_url;
-(void)setTitle:(NSString*)title;
-(void)setCommentCount:(NSInteger)comment_count;
-(void)setBookmarkCount:(NSInteger)bookmark_count;
@end

@interface CollectionsCollectionViewController : UIViewController
@property(nonatomic) BOOL is_container_view_controller;

-(instancetype)initWithAxis:(UICollectionViewScrollDirection)axis;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages axis:(UICollectionViewScrollDirection)axis;
-(instancetype)initWithDataProvider:(CollectionsPageableDataProvider*)pageable_data_provider axis:(UICollectionViewScrollDirection)axis;

-(void)setPages:(anixart::Pageable<anixart::Collection>::UPtr)pages;
-(void)setDataProvider:(CollectionsPageableDataProvider*)pageable_data_provider;

-(void)reload;
-(void)refresh;

-(void)setHeaderView:(UIView*)header_view;

@end


#endif /* CollectionsTableViewController_h */
