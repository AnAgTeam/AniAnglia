//
//  ReleaseTableViewCell.h
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#ifndef ReleaseTableViewCell_h
#define ReleaseTableViewCell_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ReleaseTableViewCell : UITableViewCell

+(NSString*)getIdentifier;
+(UIColor*)getBadgeColor:(double)rating;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;

-(void)setImageUrl:(NSURL*)image_url;
-(void)setTitle:(NSString*)title;
-(void)setDescription:(NSString*)description;
-(void)setAccesibilityView:(UIView*)accesibility_view;
-(void)setRating:(double)rating;
-(void)setEpCount:(NSUInteger)ep_count;

@end


#endif /* ReleaseTableViewCell_h */
