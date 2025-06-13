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
#import "StringCvt.h"

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
    _image_view.layer.cornerRadius = 8;
    _image_view.clipsToBounds = YES;
    _image_view.contentMode = UIViewContentModeScaleAspectFill;
    _image_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 10, 0);
    
    _title_label = [UILabel new];
    _title_label.numberOfLines = 2;
    _title_label.font = [UIFont boldSystemFontOfSize:_title_label.font.pointSize];
    
    _ep_count_label = [UILabel new];
    
    _description_label = [UILabel new];
    _description_label.textAlignment = NSTextAlignmentJustified;
    _description_label.numberOfLines = -1;
    
    _rating_label = [UILabel new];
    _rating_label.layer.cornerRadius = RATING_BADGE_HEIGHT / 2;
    _rating_label.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    _rating_label.layer.masksToBounds = YES;
    _rating_label.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_image_view];
    [self.contentView addSubview:_title_label];
    [self.contentView addSubview:_ep_count_label];
    [self.contentView addSubview:_description_label];
    [_image_view addSubview:_rating_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor multiplier:0.93],
        [_image_view.widthAnchor constraintEqualToAnchor:_image_view.heightAnchor multiplier:(10. / 16)],
        
        [_title_label.topAnchor constraintEqualToAnchor:_image_view.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:15],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_ep_count_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_ep_count_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_ep_count_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        
        [_description_label.topAnchor constraintEqualToAnchor:_ep_count_label.bottomAnchor constant:5],
        [_description_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_description_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_description_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_rating_label.trailingAnchor constraintEqualToAnchor:_image_view.trailingAnchor],
        [_rating_label.heightAnchor constraintEqualToConstant:RATING_BADGE_HEIGHT],
        [_rating_label.widthAnchor constraintEqualToAnchor:_rating_label.heightAnchor],
        [_rating_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
    ]];
}

-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _description_label.textColor = [AppColorProvider textSecondaryColor];
    _ep_count_label.textColor = [AppColorProvider textSecondaryColor];
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

-(void)setEpCount:(NSUInteger)ep_count totalEpCount:(NSUInteger)total_ep_count {
    NSString* total_episodes_count = total_ep_count != 0 ? [@(total_ep_count) stringValue] : @"?";
    _ep_count_label.text = [NSString stringWithFormat:@"%@: %@/%@", NSLocalizedString(@"app.release_search.ep_count.text", ""), [@(ep_count) stringValue], total_episodes_count];
    [_ep_count_label sizeToFit];
}

-(void)setRating:(double)rating {
    rating = round(rating * 10) / 10;
    _rating_label.text = [@(rating) stringValue];
    _rating_label.backgroundColor = [ReleaseTableViewCell getBadgeColor:rating];
}

@end
