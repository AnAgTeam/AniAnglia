//
//  StarsVoteView.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.06.2025.
//

#ifndef StarsVoteView_h
#define StarsVoteView_h

#import <UIKit/UIKit.h>

@interface StarsVoteView : UIStackView

-(instancetype)init;
-(instancetype)initWithTotalStarsCount:(NSInteger)total_stars_count;

-(void)setStarsColor:(UIColor*)stars_color;
-(void)setFilledStarCount:(NSInteger)filled_star_count;

@end

#endif /* StarsVoteView_h */
