//
//  ReleaseHistoryTableViewCell.h
//  AniAnglia
//
//  Created by Toilettrauma on 11.06.2025.
//

#ifndef ReleaseHistoryTableViewCell_h
#define ReleaseHistoryTableViewCell_h

#import <UIKit/UIKit.h>

@interface ReleaseHistoryTableViewCell : UITableViewCell

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setEpisode:(NSString*)episode;
-(void)setTime:(NSString*)time;

@end

#endif /* ReleaseHistoryTableViewCell_h */
