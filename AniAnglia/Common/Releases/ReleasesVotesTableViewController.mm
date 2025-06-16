//
//  ReleasesVotesTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesVotesTableViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "TimeCvt.h"
#import "StarsVoteView.h"

@interface ReleasesVotesTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) StarsVoteView* stars_view;
@property(nonatomic, retain) UILabel* vote_time_label;

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setStarsCount:(NSInteger)stars_count;
-(void)setVoteTime:(NSString*)vote_time;
@end

@interface ReleasesVotesTableViewController ()
@end

@implementation ReleasesVotesTableViewCell

+(NSString*)getIdentifier {
    return @"ReleasesVotesTableViewCell";
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
    
    _vote_time_label = [UILabel new];
    
    _stars_view = [StarsVoteView new];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_vote_time_label];
    [self addSubview:_stars_view];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _vote_time_label.translatesAutoresizingMaskIntoConstraints = NO;
    _stars_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(10. / 16)],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:8],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_stars_view.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_stars_view.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_stars_view.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        
        [_vote_time_label.topAnchor constraintEqualToAnchor:_stars_view.topAnchor],
        [_vote_time_label.leadingAnchor constraintEqualToAnchor:_stars_view.trailingAnchor constant:5],
        [_vote_time_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
    ]];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _vote_time_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setStarsCount:(NSInteger)stars_count {
    [_stars_view setFilledStarCount:stars_count];
}
-(void)setVoteTime:(NSString*)vote_time {
    _vote_time_label.text = vote_time;
}
@end

@implementation ReleasesVotesTableViewController

-(void)tableViewDidLoad {
    [self.tableView registerClass:ReleasesVotesTableViewCell.class forCellReuseIdentifier:[ReleasesVotesTableViewCell getIdentifier]];
}

-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path withRelease:(anixart::Release::Ptr)release {
    ReleasesVotesTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleasesVotesTableViewCell getIdentifier] forIndexPath:index_path];
    
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setStarsCount:release->my_vote];
    [cell setVoteTime:[NSDateFormatter localizedStringFromDate:anix_time_point_to_nsdate(release->voted_date) dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
    
    return cell;
}

@end
