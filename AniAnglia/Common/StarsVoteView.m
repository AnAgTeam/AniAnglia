//
//  StarsVoteView.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.06.2025.
//

#import <Foundation/Foundation.h>
#import "StarsVoteView.h"
#import "AppColor.h"

@interface StarsVoteView ()
@property(nonatomic) NSInteger total_stars_count;
@property(nonatomic, retain) NSMutableArray<UIImageView*>* stars_views;

@end

@implementation StarsVoteView

-(instancetype)init {
    return [self initWithTotalStarsCount:5];
}
-(instancetype)initWithTotalStarsCount:(NSInteger)total_stars_count {
    self = [super init];
    
    _total_stars_count = total_stars_count;
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    self.axis = UILayoutConstraintAxisHorizontal;
    self.distribution = UIStackViewDistributionEqualSpacing;
    self.alignment = UIStackViewAlignmentCenter;
    
    _stars_views = [NSMutableArray arrayWithCapacity:_total_stars_count];
    for (size_t i = 0; i < _total_stars_count; ++i) {
        UIImageView* star_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]];
        [_stars_views addObject:star_image_view];
        
        [self addArrangedSubview:star_image_view];
        star_image_view.translatesAutoresizingMaskIntoConstraints = NO;
        [star_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor].active = YES;
    }
}

-(void)setupLayout {
    [self setStarsColor:[AppColorProvider primaryColor]];
}

-(void)setStarsColor:(UIColor*)stars_color {
    for (size_t i = 0; i < [_stars_views count]; ++i) {
        _stars_views[i].tintColor = [AppColorProvider primaryColor];
    }
}

-(void)setFilledStarCount:(NSInteger)filled_star_count {
    for (size_t i = 0; i < [_stars_views count]; ++i) {
        _stars_views[i].image = [UIImage systemImageNamed:(i < filled_star_count ? @"star.fill" : @"star")];
    }
}

@end
