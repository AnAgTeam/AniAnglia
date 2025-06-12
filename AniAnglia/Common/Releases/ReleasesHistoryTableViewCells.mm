//
//  ReleasesHistoryTableViewCell.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleaseHistoryTableViewCells.h"
#import "LoadableView.h"
#import "AppColor.h"

@interface ReleaseHistoryTableViewCell ()
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* episode_label;
@property(nonatomic, retain) UILabel* time_label;

@end

@implementation ReleaseHistoryTableViewCell

+(NSString*)getIdentifier {
    return @"ReleaseHistoryTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    _title_label = [UILabel new];
    _episode_label = [UILabel new];
    _time_label = [UILabel new];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_episode_label];
    [self addSubview:_time_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _episode_label.translatesAutoresizingMaskIntoConstraints = NO;
    _time_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(9. / 16)],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_episode_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_episode_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        
        [_time_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_time_label.leadingAnchor constraintEqualToAnchor:_episode_label.trailingAnchor constant:5],
        [_time_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]
    ]];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _episode_label.textColor = [AppColorProvider textSecondaryColor];
    _time_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setEpisode:(NSString*)episode {
    _episode_label.text = episode;
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setTime:(NSString*)time {
    _time_label.text = time;
}

@end
