//
//  ReleaseTableViewCell.m
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleaseTableViewCell.h"
#import "LoadableView.h"
#import "AppColor.h"

@interface ReleaseTableViewCell ()
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* description_label;
@property(nonatomic, retain) UILabel* ep_count_label;
@property(nonatomic, retain) UILabel* rating_label;

@end

@implementation ReleaseTableViewCell

static const CGFloat RATING_BADGE_HEIGHT = 35;

+(NSString*)getIdentifier {
    return @"ReleaseTableViewCell";
}

+(UIColor*)getBadgeColor:(double)rating {
    if (rating >= 4) {
        return [UIColor systemGreenColor];
    }
    else if (rating >= 3) {
        return[UIColor systemOrangeColor];
    }
    else if (rating > 0) {
        return [UIColor systemRedColor];
    }
    else {
        return [UIColor systemGrayColor];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.layer.cornerRadius = 6.0;
    _image_view.clipsToBounds = YES;
    _image_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 10, 0);
    
    _title_label = [UILabel new];
//    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 2;
    _title_label.font = [_title_label.font fontWithSize:23];
    
    _ep_count_label = [UILabel new];
    
    _description_label = [UILabel new];
    _description_label.textAlignment = NSTextAlignmentJustified;
    _description_label.numberOfLines = -1;
    
    _rating_label = [UILabel new];
    _rating_label.layer.cornerRadius = RATING_BADGE_HEIGHT / 2;
    _rating_label.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    _rating_label.layer.masksToBounds = YES;
    _rating_label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_ep_count_label];
    [self addSubview:_description_label];
    [_image_view addSubview:_rating_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.93],
        [_image_view.widthAnchor constraintEqualToAnchor:_image_view.heightAnchor multiplier:(9. / 16)],
        
        [_title_label.topAnchor constraintEqualToAnchor:_image_view.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:8],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        //    [_title_label.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.25],
        
        [_ep_count_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_ep_count_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_ep_count_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_description_label.topAnchor constraintEqualToAnchor:_ep_count_label.bottomAnchor],
        [_description_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
        [_description_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_description_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_rating_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
        [_rating_label.trailingAnchor constraintEqualToAnchor:_image_view.trailingAnchor],
        [_rating_label.heightAnchor constraintEqualToConstant:RATING_BADGE_HEIGHT],
        [_rating_label.widthAnchor constraintEqualToAnchor:_rating_label.heightAnchor],
    ]];
    [_title_label sizeToFit];
    [_ep_count_label sizeToFit];
    [_description_label sizeToFit];
}

-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _description_label.textColor = [AppColorProvider textSecondaryColor];
    _ep_count_label.textColor = [AppColorProvider textColor];
    _rating_label.textColor = [AppColorProvider textColor];
    _rating_label.backgroundColor = [UIColor systemGrayColor];
}

-(void)setImageUrl:(NSURL*)image_url {
    [_image_view tryLoadImageWithURL:image_url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setDescription:(NSString*)description; {
    _description_label.text = description;
}

-(void)setEpCount:(NSUInteger)ep_count {
    _ep_count_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.release_search.ep_count.text", ""), [@(ep_count) stringValue]];
    [_ep_count_label sizeToFit];
}

-(void)setRating:(double)rating {
    rating = round(rating * 10) / 10;
    _rating_label.text = [@(rating) stringValue];
    _rating_label.backgroundColor = [ReleaseTableViewCell getBadgeColor:rating];
}

@end
