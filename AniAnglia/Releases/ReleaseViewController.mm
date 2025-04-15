//
//  ReleaseViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 29.08.2024.
//

#import <Foundation/Foundation.h>
#import "ReleaseViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "StringCvt.h"
#import "TypeSelectViewController.h"
#import "LoadableView.h"
#import "TimeCvt.h"
#import "DynamicTableView.h"
#import "ProfileListsView.h"
#import "CommentsTableViewController.h"
#import "CommentRepliesViewController.h"

@class ReleaseRatingView;
@class ReleaseVideoBlocksView;
@class ReleasePreviewsView;
@class ReleaseRelatedView;
@class ReleaseCommentsView;

@protocol ReleaseRatingViewDelegate <NSObject>
-(void)releaseRatingView:(ReleaseRatingView*)release_rating_view didPressedVote:(NSInteger)vote;
@end

@protocol ReleaseVideoBlocksViewDelegate <NSObject>
-(void)releaseVideoBlocksView:(ReleaseVideoBlocksView*)release_video_blocks didSelectBanner:(anixart::ReleaseVideoBanner::Ptr)block;
-(void)didShowAllPressedForReleaseVideoBlocksView:(ReleaseVideoBlocksView*)release_video_blocks;
@end

@protocol ReleasePreviewViewDelegate <NSObject>
-(void)releasePreviewView:(ReleasePreviewsView*)release_preview_view didSelectPreviewWithUrl:(NSURL*)url;
@end

@protocol ReleaseRelatedViewDelegate <NSObject>
-(void)releaseRelatedView:(ReleaseRelatedView*)release_related__view didSelectRelease:(anixart::Release::Ptr)release;
@end

@protocol ReleaseCommentsViewDelegate <NSObject>
-(void)didShowAllPressedForReleaseCommentsView:(ReleaseCommentsView*)release_comments_view;
@end

@interface ReleaseVoteIndicatorView : UIView
@property(nonatomic, retain, readonly) NSString* name;
@property(nonatomic, readonly) NSInteger vote_count;
@property(nonatomic, readonly) NSInteger vote_total_count;
@property(nonatomic, retain) UILabel* vote_number_label;
@property(nonatomic, retain) UIView* blank_indicator_view;
@property(nonatomic, retain) UIView* filled_indicator_view;
@property(nonatomic, retain) NSLayoutConstraint* filled_indicator_width;

-(instancetype)initWithName:(NSString*)name voteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)total_vote_count;

-(void)setVoteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)total_vote_count;
@end

@interface ReleaseNamedImageView : UIView
@property(nonatomic, retain, readonly) UIImage* image;
@property(nonatomic, retain, readonly) NSString* content;
@property(nonatomic, retain) UIImageView* image_view;
@property(nonatomic, retain) UILabel* content_label;

-(instancetype)initWithImage:(UIImage*)image content:(NSString*)content;
@end

@interface ReleaseVideoBlocksCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;

+(NSString*)getIdentifier;
-(instancetype)initWithFrame:(CGRect)frame;

-(void)setTitle:(NSString*)title;
-(void)setImageUrl:(NSURL*)image_url;
@end

@interface ReleaseVideoBlocksView : LoadableView <UICollectionViewDataSource, UICollectionViewDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, weak) id<ReleaseVideoBlocksViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIButton* show_all_button;
@property(nonatomic, retain) UICollectionView * videos_collection_view;

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release;
@end

@interface ReleaseRatingView : UIView {
    anixart::Release::Ptr _release;
}
@property(nonatomic, weak) id<ReleaseRatingViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UILabel* overall_label;
@property(nonatomic, retain) UILabel* total_votes_label;
@property(nonatomic, retain) UIStackView* votes_indicators_stack_view;
@property(nonatomic, retain) UIImageView* profile_image_view;
@property(nonatomic, retain) NSArray<ReleaseVoteIndicatorView*>* vote_indicators;
@property(nonatomic, retain) NSArray<UIButton*>* vote_buttons;
@property(nonatomic, retain) UIStackView* my_votes_stack_view;

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release;
@end

@interface ReleasePreviewsCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) LoadableImageView* image_view;

+(NSString*)getIdentifier;
-(instancetype)initWithFrame:(CGRect)frame;

-(void)setImageUrl:(NSURL*)image_url;
@end

@interface ReleasePreviewsView : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, weak) id<ReleasePreviewViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UICollectionView* previews_collection_view;

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release;
@end

@interface ReleaseRelatedTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* year_label;
@property(nonatomic, retain) UILabel* rating_label;
@property(nonatomic, retain) UILabel* category_label;

+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setYear:(NSString*)year;
-(void)setRating:(NSString*)rating;
-(void)setCategory:(NSString*)category;
@end

@interface ReleaseRelatedView : UIView <UITableViewDataSource, UITableViewDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, weak) id<ReleaseRelatedViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UITableView* related_table_view;

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release;
@end

@interface ReleaseCommentsView : UIView
@property(nonatomic, weak) id<ReleaseCommentsViewDelegate> delegate;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIButton* show_all_button;
@property(nonatomic, strong) UIView* view;

-(instancetype)initWithViewController:(UIViewController*)view_controller;
@end

@interface ReleaseViewController () <ReleaseRatingViewDelegate, ReleaseVideoBlocksViewDelegate, ReleasePreviewViewDelegate, ReleaseRelatedViewDelegate, ReleaseCommentsViewDelegate, CommentsTableViewControllerDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic) anixart::ReleaseID release_id;

@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) LoadableView* loading_view;
@property(nonatomic, retain) UIStackView* content_stack_view;

@property(nonatomic, retain) LoadableImageView* release_image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* orig_title_label;
@property(nonatomic, retain) UIStackView* actions_stack_view;
@property(nonatomic, retain) UIButton* add_list_button;
@property(nonatomic, retain) UIButton* bookmark_button;
@property(nonatomic, retain) UIButton* play_button;
@property(nonatomic, retain) UILabel* note_label;

@property(nonatomic, retain) UIStackView* info_stack_view;
@property(nonatomic, retain) ReleaseNamedImageView* prod_info_view;
@property(nonatomic, retain) ReleaseNamedImageView* ep_info_view;
@property(nonatomic, retain) ReleaseNamedImageView* status_info_view;
@property(nonatomic, retain) ReleaseNamedImageView* author_info_view;
@property(nonatomic, retain) UILabel* tags_label;
@property(nonatomic, retain) UILabel* description_label;

@property(nonatomic, retain) ReleaseRatingView* rating_view;
@property(nonatomic, retain) ProfileListsView* lists_view;
@property(nonatomic, retain) ReleaseVideoBlocksView* video_blocks_view;
@property(nonatomic, retain) ReleasePreviewsView* previews_view;
@property(nonatomic, retain) ReleaseRelatedView* related_view;
@property(nonatomic, retain) ReleaseCommentsView* comments_view;
@property(nonatomic, retain) CommentsTableViewController* comments_view_controller;

@end

@implementation ReleaseVoteIndicatorView
-(instancetype)initWithName:(NSString*)name voteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)total_vote_count {
    self = [super init];
    
    _name = name;
    _vote_count = vote_count;
    _vote_total_count = total_vote_count;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _vote_number_label = [UILabel new];
    _vote_number_label.text = _name;
    _vote_number_label.font = [UIFont systemFontOfSize:10];
    [_vote_number_label sizeToFit];
    _blank_indicator_view = [UIView new];
    _blank_indicator_view.clipsToBounds = YES;
    _blank_indicator_view.layer.cornerRadius = 8.0;
    _filled_indicator_view = [UIView new];
    
    [self addSubview:_vote_number_label];
    [self addSubview:_blank_indicator_view];
    [_blank_indicator_view addSubview:_filled_indicator_view];
    
    _vote_number_label.translatesAutoresizingMaskIntoConstraints = NO;
    _blank_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _filled_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _filled_indicator_width = [_filled_indicator_view.widthAnchor constraintEqualToAnchor:_blank_indicator_view.widthAnchor multiplier:_vote_total_count > 0 ? (double)_vote_count / _vote_total_count : 0];
    [NSLayoutConstraint activateConstraints:@[
        [_vote_number_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_vote_number_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_vote_number_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_blank_indicator_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_blank_indicator_view.leadingAnchor constraintEqualToAnchor:_vote_number_label.trailingAnchor constant:1],
        [_blank_indicator_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_blank_indicator_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_filled_indicator_view.topAnchor constraintEqualToAnchor:_blank_indicator_view.topAnchor],
        [_filled_indicator_view.leadingAnchor constraintEqualToAnchor:_blank_indicator_view.leadingAnchor],
        [_filled_indicator_view.trailingAnchor constraintLessThanOrEqualToAnchor:_blank_indicator_view.trailingAnchor],
        _filled_indicator_width,
        [_filled_indicator_view.bottomAnchor constraintEqualToAnchor:_blank_indicator_view.bottomAnchor]
    ]];
    [_vote_number_label sizeToFit];
}
-(void)setupLayout {
    _vote_number_label.textColor = [AppColorProvider textSecondaryColor];
    _blank_indicator_view.backgroundColor = [AppColorProvider foregroundColor1];
    _filled_indicator_view.backgroundColor = [AppColorProvider primaryColor];
}

-(void)setVoteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)vote_total_count {
    _vote_count = vote_count;
    _vote_total_count = vote_total_count;
    _filled_indicator_width.active = NO;
    _filled_indicator_width = [_filled_indicator_view.widthAnchor constraintEqualToAnchor:_blank_indicator_view.widthAnchor multiplier:_vote_total_count > 0 ? _vote_count / _vote_total_count : 0];
    _filled_indicator_width.active = YES;
    [self setNeedsLayout];
}
@end

@implementation ReleaseNamedImageView
-(instancetype)initWithImage:(UIImage*)image content:(NSString*)content {
    self = [super init];
    
    _image = image;
    _content = content;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [[UIImageView alloc] initWithImage:_image];
    _content_label = [UILabel new];
    _content_label.text = _content;
    _content_label.numberOfLines = 0;
    
    [self addSubview:_image_view];
    [self addSubview:_content_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.widthAnchor constraintEqualToConstant:22],
//        [_image_view.heightAnchor constraintEqualToConstant:20],
        
        [_content_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_content_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_content_label sizeToFit];
}
-(void)setupLayout {
    _image_view.tintColor = [AppColorProvider textSecondaryColor];
    _content_label.textColor = [AppColorProvider textColor];
}
@end

@implementation ReleaseVideoBlocksCollectionViewCell
+(NSString*)getIdentifier {
    return @"ReleaseViewsCollectionViewCell";
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.0;
    
    _image_view = [LoadableImageView new];
    _image_view.contentMode = UIViewContentModeScaleAspectFill;
    _title_label = [UILabel new];
    _title_label.font = [UIFont systemFontOfSize:36];
    _title_label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_image_view];
    [_image_view addSubview:_title_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_image_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [_title_label.topAnchor constraintGreaterThanOrEqualToAnchor:_image_view.topAnchor],
        [_title_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_image_view.leadingAnchor],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:_image_view.trailingAnchor],
        [_title_label.bottomAnchor constraintLessThanOrEqualToAnchor:_image_view.bottomAnchor],
        [_title_label.centerXAnchor constraintEqualToAnchor:_image_view.centerXAnchor],
        [_title_label.centerYAnchor constraintEqualToAnchor:_image_view.centerYAnchor],
    ]];
    [_title_label sizeToFit];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _title_label.backgroundColor = [[AppColorProvider backgroundColor] colorWithAlphaComponent:0.6];
}

-(void)setTitle:(NSString*)title {
    _title_label.text = title;
    [_title_label sizeToFit];
}
-(void)setImageUrl:(NSURL*)image_url {
    if (!image_url) {
        _image_view.image = nil;
        return;
    }
    [_image_view tryLoadImageWithURL:image_url];
}
@end

@implementation ReleaseRatingView
-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release {
    self = [super init];
    
    _release = release;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.text = NSLocalizedString(@"app.release.rating.title", "");
    _me_label.font = [UIFont systemFontOfSize:22];
    _overall_label = [UILabel new];
    _overall_label.text = [@(round(_release->grade * 10) / 10) stringValue];
    _overall_label.font = [UIFont systemFontOfSize:38];
    _overall_label.textAlignment = NSTextAlignmentCenter;
    _total_votes_label = [UILabel new];
    _total_votes_label.text = [NSString stringWithFormat:@"%d %@", _release->vote_count, NSLocalizedString(@"app.release.rating.vote_count.end", "")];
    _total_votes_label.textAlignment = NSTextAlignmentCenter;
    _votes_indicators_stack_view = [UIStackView new];
    _votes_indicators_stack_view.axis = UILayoutConstraintAxisVertical;
    _votes_indicators_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _votes_indicators_stack_view.alignment = UIStackViewAlignmentLeading;
    _profile_image_view = [LoadableImageView new];
    _profile_image_view.layer.cornerRadius = 20;
    _my_votes_stack_view = [UIStackView new];
    _my_votes_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _my_votes_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _my_votes_stack_view.alignment = UIStackViewAlignmentCenter;
    
    _vote_indicators = @[
        [[ReleaseVoteIndicatorView alloc] initWithName:@"5" voteCount:_release->vote5_count totalVoteCount:_release->vote_count],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"4" voteCount:_release->vote4_count totalVoteCount:_release->vote_count],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"3" voteCount:_release->vote3_count totalVoteCount:_release->vote_count],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"2" voteCount:_release->vote2_count totalVoteCount:_release->vote_count],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"1" voteCount:_release->vote1_count totalVoteCount:_release->vote_count]
    ];
    
    _vote_buttons = @[
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton]
    ];
    
    [self addSubview:_me_label];
    [self addSubview:_overall_label];
    [self addSubview:_total_votes_label];
    [self addSubview:_votes_indicators_stack_view];
    [self addSubview:_my_votes_stack_view];
    for (UIImageView* image_view : _vote_indicators) {
        image_view.translatesAutoresizingMaskIntoConstraints = NO;
        [_votes_indicators_stack_view addArrangedSubview:image_view];
    }
    [_my_votes_stack_view addArrangedSubview:[UIView new]];
    [_my_votes_stack_view addArrangedSubview:_profile_image_view];
    for (UIButton* vote_button : _vote_buttons) {
        [_my_votes_stack_view addArrangedSubview:vote_button];
    }
    [_my_votes_stack_view addArrangedSubview:[UIView new]];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _overall_label.translatesAutoresizingMaskIntoConstraints = NO;
    _total_votes_label.translatesAutoresizingMaskIntoConstraints = NO;
    _votes_indicators_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _my_votes_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _profile_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_overall_label.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_overall_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_overall_label.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.widthAnchor multiplier:0.35],
        [_overall_label.heightAnchor constraintEqualToConstant:90],
        
        [_total_votes_label.topAnchor constraintEqualToAnchor:_overall_label.bottomAnchor constant:2],
        [_total_votes_label.leadingAnchor constraintEqualToAnchor:_overall_label.leadingAnchor],
        [_total_votes_label.trailingAnchor constraintEqualToAnchor:_overall_label.trailingAnchor],
        
        [_votes_indicators_stack_view.topAnchor constraintEqualToAnchor:_overall_label.topAnchor],
        [_votes_indicators_stack_view.leadingAnchor constraintEqualToAnchor:_overall_label.trailingAnchor],
        [_votes_indicators_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_votes_indicators_stack_view.bottomAnchor constraintEqualToAnchor:_total_votes_label.bottomAnchor],
        
        [_vote_indicators[0].widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor],
        [_vote_indicators[1].widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor],
        [_vote_indicators[2].widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor],
        [_vote_indicators[3].widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor],
        [_vote_indicators[4].widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor],
        
        [_profile_image_view.widthAnchor constraintEqualToAnchor:_my_votes_stack_view.heightAnchor],
        [_profile_image_view.heightAnchor constraintEqualToAnchor:_my_votes_stack_view.heightAnchor],
        
        [_my_votes_stack_view.topAnchor constraintEqualToAnchor:_votes_indicators_stack_view.bottomAnchor constant:5],
        [_my_votes_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_my_votes_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_my_votes_stack_view.heightAnchor constraintEqualToConstant:40],
        [_my_votes_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    [_me_label sizeToFit];
    [_overall_label sizeToFit];
    [_total_votes_label sizeToFit];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
    _overall_label.textColor = [AppColorProvider textColor];
    _total_votes_label.textColor = [AppColorProvider textSecondaryColor];
    _profile_image_view.backgroundColor = [AppColorProvider foregroundColor1];
}

-(UIButton*)makeVoteButton {
    UIButton* vote_button = [UIButton new];
    [vote_button setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [vote_button addTarget:self action:@selector(onSomeVoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return vote_button;
}

-(IBAction)onSomeVoteButtonPressed:(UIButton*)vote_button {
    NSInteger index = [_vote_buttons indexOfObject:vote_button];
    if (index != NSNotFound) {
        [_delegate releaseRatingView:self didPressedVote:index + 1];
    }
}
@end

@implementation ReleaseVideoBlocksView

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release = release;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.text = NSLocalizedString(@"app.release.video_blocks.title", "");
    _me_label.font = [UIFont systemFontOfSize:22];
    _show_all_button = [UIButton new];
    [_show_all_button setTitle:NSLocalizedString(@"app.release.video_block.show_all_button.title", "") forState:UIControlStateNormal];
    [_show_all_button addTarget:self action:@selector(onShowAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _videos_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _videos_collection_view.dataSource = self;
    _videos_collection_view.delegate = self;
    [_videos_collection_view registerClass:ReleaseVideoBlocksCollectionViewCell.class forCellWithReuseIdentifier:[ReleaseVideoBlocksCollectionViewCell getIdentifier]];
    _videos_collection_view.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_me_label];
    [self addSubview:_show_all_button];
    [self addSubview:_videos_collection_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _show_all_button.translatesAutoresizingMaskIntoConstraints = NO;
    _videos_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        [_me_label.heightAnchor constraintEqualToConstant:30],
        
        [_show_all_button.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_show_all_button.leadingAnchor constraintEqualToAnchor:_me_label.trailingAnchor],
        [_show_all_button.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_show_all_button.bottomAnchor constraintEqualToAnchor:_me_label.bottomAnchor],
        
        [_videos_collection_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_videos_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor constant:5],
        [_videos_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_videos_collection_view.heightAnchor constraintEqualToConstant:180],
        [_videos_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _me_label.textColor = [AppColorProvider textColor];
    [_show_all_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _release->video_banners.size();
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ReleaseVideoBlocksCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ReleaseVideoBlocksCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::ReleaseVideoBanner::Ptr video_block = _release->video_banners[index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(video_block->image_url)];
    
    [cell setTitle:TO_NSSTRING(video_block->name)];
    [cell setImageUrl:image_url];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.frame.size.height * (16. / 9), collection_view.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    [_delegate releaseVideoBlocksView:self didSelectBanner:_release->video_banners[index]];
}

-(IBAction)onShowAllButtonPressed:(UIButton*)sender {
    [_delegate didShowAllPressedForReleaseVideoBlocksView:self];
}
@end

@implementation ReleasePreviewsCollectionViewCell

+(NSString*)getIdentifier {
    return @"ReleasePreviewsCollectionViewCell";
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8;
    _image_view = [LoadableImageView new];
    _image_view.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_image_view];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_image_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_image_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
}

-(void)setImageUrl:(NSURL*)image_url {
    [_image_view tryLoadImageWithURL:image_url];
}
@end

@implementation ReleasePreviewsView

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release = release;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.release.previews.title", "");
    
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _previews_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_previews_collection_view registerClass:ReleasePreviewsCollectionViewCell.class forCellWithReuseIdentifier:[ReleasePreviewsCollectionViewCell getIdentifier]];
    _previews_collection_view.dataSource = self;
    _previews_collection_view.delegate = self;
    _previews_collection_view.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_me_label];
    [self addSubview:_previews_collection_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _previews_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_previews_collection_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_previews_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor constant:5],
        [_previews_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_previews_collection_view.heightAnchor constraintEqualToConstant:180],
        [_previews_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_me_label sizeToFit];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
    self.backgroundColor = [AppColorProvider backgroundColor];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _release->screenshot_image_urls.size();
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ReleasePreviewsCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ReleasePreviewsCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(_release->screenshot_image_urls[index])];

    [cell setImageUrl:image_url];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.frame.size.height * (16. / 9), collection_view.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(_release->screenshot_image_urls[index])];
    [_delegate releasePreviewView:self didSelectPreviewWithUrl:image_url];
}
@end

@implementation ReleaseRelatedTableViewCell

+(NSString*)getIdentifier {
    return @"ReleaseRelatedTableViewCell";
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
    _image_view.layer.cornerRadius = 2;
    _title_label = [UILabel new];
    _title_label.numberOfLines = 2;
    _year_label = [UILabel new];
    _rating_label = [UILabel new];
    _category_label = [UILabel new];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_year_label];
    [self addSubview:_rating_label];
    [self addSubview:_category_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _year_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    _category_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(9. / 16)],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_year_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_year_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],

        [_rating_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_rating_label.leadingAnchor constraintEqualToAnchor:_year_label.trailingAnchor constant:5],

        [_category_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_category_label.leadingAnchor constraintEqualToAnchor:_rating_label.trailingAnchor constant:5],
        [_category_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]
    ]];
    
    [_title_label sizeToFit];
    [_year_label sizeToFit];
    [_rating_label sizeToFit];
    [_category_label sizeToFit];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _year_label.textColor = [AppColorProvider textColor];
    _rating_label.textColor = [AppColorProvider textColor];
    _category_label.textColor = [AppColorProvider textColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setYear:(NSString*)year {
    _year_label.text = year;
}
-(void)setRating:(NSString*)rating {
    _rating_label.text = rating;
}
-(void)setCategory:(NSString*)category {
    _category_label.text = category;
}
@end

@implementation ReleaseRelatedView : UIView

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release {
    self = [super init];
    
    _release = release;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.text = NSLocalizedString(@"app.release.related.title", "");
    _me_label.font = [UIFont systemFontOfSize:22];
    _related_table_view = [UITableView new];
    [_related_table_view registerClass:ReleaseRelatedTableViewCell.class forCellReuseIdentifier:[ReleaseRelatedTableViewCell getIdentifier]];
    _related_table_view.dataSource = self;
    _related_table_view.delegate = self;
    _related_table_view.scrollEnabled = NO;
    
    [self addSubview:_me_label];
    [self addSubview:_related_table_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _related_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_related_table_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_related_table_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_related_table_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_related_table_view.heightAnchor constraintEqualToConstant:[self tableView:_related_table_view numberOfRowsInSection:0] * [self tableView:_related_table_view heightForRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]]],
        [_related_table_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_me_label sizeToFit];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _me_label.textColor = [AppColorProvider textColor];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _release->related_releases.size();
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 100;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    ReleaseRelatedTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleaseRelatedTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Release::Ptr release = _release->related_releases[index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    NSInteger rating = round(release->grade * 10) / 10;
    // TODO: add global function for category name
    NSString* category;
    switch(release->category) {
        case anixart::Release::Category::Series:
            category = NSLocalizedString(@"app.release.category.series.name", "");
            break;
        case anixart::Release::Category::Movies:
            category = NSLocalizedString(@"app.release.category.movies.name", "");
            break;
        case anixart::Release::Category::Ova:
            category = NSLocalizedString(@"app.release.category.ova.name", "");
            break;
        default:
            category = NSLocalizedString(@"app.release.category.unknown.name", "");
            break;
    }
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setYear:TO_NSSTRING(release->year)];
    [cell setRating:[@(rating) stringValue]];
    [cell setCategory:category];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::Release::Ptr release = _release->related_releases[index];
    [_delegate releaseRelatedView:self didSelectRelease:release];
}
@end

@implementation ReleaseCommentsView

-(instancetype)initWithViewController:(UIViewController*)view_controller {
    self = [super init];
    
    _view = view_controller.view;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.text = NSLocalizedString(@"app.release.comments.title", "");
    _me_label.font = [UIFont systemFontOfSize:22];
    
    _show_all_button = [UIButton new];
    [_show_all_button addTarget:self action:@selector(onShowAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_show_all_button setTitle:NSLocalizedString(@"app.release.comments.show_all_button.title", "") forState:UIControlStateNormal];
    
    [self addSubview:_me_label];
    [self addSubview:_show_all_button];
    [self addSubview:_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _show_all_button.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        
        [_show_all_button.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_show_all_button.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor],
        [_show_all_button.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_show_all_button.bottomAnchor constraintEqualToAnchor:_me_label.bottomAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
    [_show_all_button setTitleColor:[AppColorProvider primaryColor] forState:UIControlStateNormal];
}

-(IBAction)onShowAllButtonPressed:(UIButton*)sender {
    [_delegate didShowAllPressedForReleaseCommentsView:self];
}
@end

@implementation ReleaseViewController

-(instancetype)initWithRelease:(anixart::Release::Ptr)release {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release = release;
    _release_id = _release->id;
    
    return self;
}
-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release_id = release_id;
    
    return self;
}

-(void)loadReleaseInfo {
    [_loading_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        self->_release = self->_api_proxy.api->releases().get_release(self->_release_id);
        return YES;
    } withUICompletion:^{
        [self->_loading_view endLoading];
        [self setup];
        [self setupLayout];
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    
    if (_release) {
        [self setup];
        [self setupLayout];
    }
    else {
        [self loadReleaseInfo];
    }
}

-(void)preSetup {
    _scroll_view = [UIScrollView new];
    _loading_view = [LoadableView new];
    
    [self.view addSubview:_loading_view];
    [self.view addSubview:_scroll_view];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loading_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [_loading_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_loading_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_loading_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_loading_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];

}

-(void)setup {
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 7;
    _content_stack_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 10, 0, 10);
    
    _release_image_view = [LoadableImageView new];
    _release_image_view.layer.cornerRadius = 8.0;
    _release_image_view.layer.masksToBounds = YES;

    _title_label = [UILabel new];
    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 0;
    _title_label.text = TO_NSSTRING(_release->title_ru);
    [_title_label setFont:[UIFont boldSystemFontOfSize:22]];
    
    _orig_title_label = [UILabel new];
    _orig_title_label.textAlignment = NSTextAlignmentJustified;
    _orig_title_label.numberOfLines = 0;
    _orig_title_label.text = TO_NSSTRING(_release->title_original);
    
    _actions_stack_view = [UIStackView new];
    _actions_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _actions_stack_view.distribution = UIStackViewDistributionEqualCentering;
    _actions_stack_view.alignment = UIStackViewAlignmentFill;
    
    _add_list_button = [UIButton new];
    [_add_list_button setTitle:[self getListStatusNameFor:_release->profile_list_status] forState:UIControlStateNormal];
    [_add_list_button setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
    [_add_list_button setMenu:[self makeAddListButtonMenu]];
    _add_list_button.showsMenuAsPrimaryAction = YES;
    _add_list_button.layer.cornerRadius = 8.0;
    _add_list_button.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    
    _bookmark_button = [UIButton new];
    [_bookmark_button setTitle:[@(_release->favorite_count) stringValue] forState:UIControlStateNormal];
    [_bookmark_button setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
    [_bookmark_button addTarget:self action:@selector(onBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _bookmark_button.layer.cornerRadius = 8.0;
    _bookmark_button.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    
    _play_button = [UIButton new];
    [_play_button setTitle:NSLocalizedString(@"app.release.play_button.title", "") forState:UIControlStateNormal];
    _play_button.layer.cornerRadius = 9.0;
    [_play_button addTarget:self action:@selector(onPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _note_label = [UILabel new];
    _note_label.text = TO_NSSTRING(_release->note);
    _note_label.numberOfLines = 0;
    _note_label.textAlignment = NSTextAlignmentJustified;
    
    _info_stack_view = [UIStackView new];
    _info_stack_view.axis = UILayoutConstraintAxisVertical;
    _info_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _info_stack_view.alignment = UIStackViewAlignmentFill;
    
    NSString* prod_info_content = [NSString stringWithFormat:@"%@, %@ %@ %@", TO_NSSTRING(_release->country), [self getSeasonNameFor:_release->season], TO_NSSTRING(_release->year), NSLocalizedString(@"app.release.general.year.end", "")];
    NSString* ep_info_content = [NSString stringWithFormat:@"%d/%d %@ %ld %@", _release->episodes_released, _release->episodes_total, NSLocalizedString(@"app.release.general.ep_info.separator", ""), _release->duration.count(), NSLocalizedString(@"app.release.general.ep_info.end", "")];
    NSString* status_info_content = [NSString stringWithFormat:@"%@, %@", [self getCategoryNameFor:_release->category], [self getStatusNameFor:_release->status]];
    NSString* author_info_content = [NSString stringWithFormat:@"%@ %@, %@ %@, %@ %@", NSLocalizedString(@"app.release.general.author_info.studio", ""), TO_NSSTRING(_release->studio), NSLocalizedString(@"app.release.general.author_info.author", ""), TO_NSSTRING(_release->author), NSLocalizedString(@"app.release.general.author_info.director", ""), TO_NSSTRING(_release->director)];
    
    _prod_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"a.circle"] content:prod_info_content];
    _ep_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"rectangle.stack"] content:ep_info_content];
    _status_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"calendar"] content:status_info_content];
    _author_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.3"] content:author_info_content];
    _tags_label = [UILabel new];
    _description_label = [UILabel new];
    _description_label.text = TO_NSSTRING(_release->description);
    _description_label.textAlignment = NSTextAlignmentJustified;
    _description_label.numberOfLines = 0;
    
    _rating_view = [[ReleaseRatingView alloc] initWithReleaseInfo:_release];
    _rating_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _rating_view.delegate = self;
    
    _lists_view = [[ProfileListsView alloc] initWithReleaseInfo:_release name:NSLocalizedString(@"app.release.lists.title", "")];
    _lists_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _video_blocks_view = [[ReleaseVideoBlocksView alloc] initWithReleaseInfo:_release];
    _video_blocks_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _video_blocks_view.delegate = self;
    
    _previews_view = [[ReleasePreviewsView alloc] initWithReleaseInfo:_release];
    _previews_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _previews_view.delegate = self;
    
    _related_view = nil;
    if (!_release->related_releases.empty()) {
        _related_view = [[ReleaseRelatedView alloc] initWithReleaseInfo:_release];
        _related_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
        _related_view.delegate = self;
    }
    
    _comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[DynamicTableView new] comments:_release->comments];
    [self addChildViewController:_comments_view_controller];
    _comments_view_controller.delegate = self;
    
    _comments_view = [[ReleaseCommentsView alloc] initWithViewController:_comments_view_controller];
    _comments_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    _comments_view.delegate = self;
    
    NSMutableArray<NSLayoutConstraint*>* _optional_view_constraints = [NSMutableArray arrayWithCapacity:5];
    
    [_scroll_view addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_release_image_view];
    [_content_stack_view addArrangedSubview:_title_label];
    [_content_stack_view addArrangedSubview:_orig_title_label];
    [_content_stack_view addArrangedSubview:_actions_stack_view];
    [_content_stack_view addArrangedSubview:_play_button];
    [_content_stack_view addArrangedSubview:_note_label];
    [_content_stack_view addArrangedSubview:_prod_info_view];
    [_content_stack_view addArrangedSubview:_ep_info_view];
    [_content_stack_view addArrangedSubview:_status_info_view];
    [_content_stack_view addArrangedSubview:_author_info_view];
    [_content_stack_view addArrangedSubview:_tags_label];
    [_content_stack_view addArrangedSubview:_description_label];
    
    [_actions_stack_view addArrangedSubview:[UIView new]];
    [_actions_stack_view addArrangedSubview:_add_list_button];
    [_actions_stack_view addArrangedSubview:[UIView new]];
    [_actions_stack_view addArrangedSubview:_bookmark_button];
    [_actions_stack_view addArrangedSubview:[UIView new]];
    
    [_content_stack_view addArrangedSubview:_rating_view];
    [_content_stack_view addArrangedSubview:_lists_view];
    [_content_stack_view addArrangedSubview:_video_blocks_view];
    [_content_stack_view addArrangedSubview:_previews_view];
    if (!_release->related_releases.empty()) {
        _related_view.translatesAutoresizingMaskIntoConstraints = NO;
        [_content_stack_view addArrangedSubview:_related_view];
        [_optional_view_constraints addObject:[_related_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor]];
    }
    [_content_stack_view addArrangedSubview:_comments_view];
    
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _release_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _orig_title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _play_button.translatesAutoresizingMaskIntoConstraints = NO;
    _note_label.translatesAutoresizingMaskIntoConstraints = NO;
    _add_list_button.translatesAutoresizingMaskIntoConstraints = NO;
    _bookmark_button.translatesAutoresizingMaskIntoConstraints = NO;
    _actions_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _prod_info_view.translatesAutoresizingMaskIntoConstraints = NO;
    _ep_info_view.translatesAutoresizingMaskIntoConstraints = NO;
    _status_info_view.translatesAutoresizingMaskIntoConstraints = NO;
    _author_info_view.translatesAutoresizingMaskIntoConstraints = NO;
    _tags_label.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_view.translatesAutoresizingMaskIntoConstraints = NO;
    _lists_view.translatesAutoresizingMaskIntoConstraints = NO;
    _video_blocks_view.translatesAutoresizingMaskIntoConstraints = NO;
    _previews_view.translatesAutoresizingMaskIntoConstraints = NO;
    _comments_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_content_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor],
        
        [_release_image_view.heightAnchor constraintEqualToConstant:340],
        [_release_image_view.widthAnchor constraintEqualToAnchor:_release_image_view.heightAnchor multiplier:(9. / 16)],
        
        [_title_label.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor constant:-50],

        [_orig_title_label.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor constant:-50],
        
        [_actions_stack_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_actions_stack_view.heightAnchor constraintEqualToConstant:30],
        
        [_prod_info_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_ep_info_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_status_info_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_author_info_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_description_label.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],

        [_play_button.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_play_button.heightAnchor constraintEqualToConstant:50],
        
        [_note_label.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],

        [_rating_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_lists_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_video_blocks_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_previews_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_comments_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
    ]];
    [NSLayoutConstraint activateConstraints:_optional_view_constraints];
    [_title_label sizeToFit];
    [_orig_title_label sizeToFit];
    [_description_label sizeToFit];
    [_note_label sizeToFit];
    
    [_release_image_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(_release->image_url)]];
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _title_label.textColor = [AppColorProvider textColor];
    _orig_title_label.textColor = [AppColorProvider textColor];
    _add_list_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_add_list_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _bookmark_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_bookmark_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _play_button.backgroundColor = [AppColorProvider primaryColor];
    [_play_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _note_label.textColor = [AppColorProvider textSecondaryColor];
//    _note_label.backgroundColor = [AppColorProvider foregroundColor1];
}

-(NSString*)getSeasonNameFor:(anixart::Release::Season)season {
    switch (season) {
        case anixart::Release::Season::Winter:
            return NSLocalizedString(@"app.release.season.winter.name", "");
        case anixart::Release::Season::Spring:
            return NSLocalizedString(@"app.release.season.spring.name", "");
        case anixart::Release::Season::Summer:
            return NSLocalizedString(@"app.release.season.summer.name", "");
        case anixart::Release::Season::Fall:
            return NSLocalizedString(@"app.release.season.fall.name", "");
        default:
            return NSLocalizedString(@"app.release.season.unknown.name", "");
    }
}
-(NSString*)getCategoryNameFor:(anixart::Release::Category)category {
    switch (category) {
        case anixart::Release::Category::Series:
            return NSLocalizedString(@"app.release.category.series.name", "");
        case anixart::Release::Category::Movies:
            return NSLocalizedString(@"app.release.category.movies.name", "");
        case anixart::Release::Category::Ova:
            return NSLocalizedString(@"app.release.category.ova.name", "");
        default:
            return NSLocalizedString(@"app.release.category.unknown.name", "");
    }
}
-(NSString*)getStatusNameFor:(anixart::Release::Status)status {
    switch (status) {
        case anixart::Release::Status::Finished:
            return NSLocalizedString(@"app.release.status.finished.name", "");
        case anixart::Release::Status::Ongoing:
            return NSLocalizedString(@"app.release.status.ongoing.name", "");
        case anixart::Release::Status::Upcoming:
            return NSLocalizedString(@"app.release.status.upcoming.name", "");
        default:
            return NSLocalizedString(@"app.release.status.unknown.name", "");
    }
}
-(NSString*)getListStatusNameFor:(anixart::Profile::ListStatus)list_status {
    switch(list_status) {
        case anixart::Profile::ListStatus::Watching:
            return NSLocalizedString(@"app.profile.list_status.watching.name", "");
            break;
        case anixart::Profile::ListStatus::Plan:
            return NSLocalizedString(@"app.profile.list_status.plan.name", "");
            break;
        case anixart::Profile::ListStatus::Watched:
            return NSLocalizedString(@"app.profile.list_status.watched.name", "");
            break;
        case anixart::Profile::ListStatus::HoldOn:
            return NSLocalizedString(@"app.profile.list_status.holdon.name", "");
            break;
        case anixart::Profile::ListStatus::Dropped:
            return NSLocalizedString(@"app.profile.list_status.dropped.name", "");
            break;
        default:
            return NSLocalizedString(@"app.profile.list_status.none.name", "");
            break;
    }
}

-(UIMenu*)makeAddListButtonMenu {
    return [UIMenu menuWithChildren:@[
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::NotWatching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::NotWatching];
        }],
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::Watching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Watching];
        }],
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::Plan] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Plan];
        }],
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::Watched] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Watched];
        }],
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::HoldOn] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::HoldOn];
        }],
        [UIAction actionWithTitle:[self getListStatusNameFor:anixart::Profile::ListStatus::Dropped] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Dropped];
        }]
    ]];
}

-(void)onAddListMenuItemSelected:(anixart::Profile::ListStatus)status {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().add_release_to_profile_list(self->_release->id, status);
        return YES;
    } withUICompletion:^{
        [self->_add_list_button setTitle:[self getListStatusNameFor:status] forState:UIControlStateNormal];
    }];
}

-(IBAction)onPlayButtonPressed:(UIButton*)sender {
    [self.navigationController pushViewController:[[TypeSelectViewController alloc] initWithReleaseID:_release->id] animated:YES];
}
-(IBAction)onBookmarkButtonPressed:(UIButton*)sender {
    // TODO
}

-(void)releaseRatingView:(ReleaseRatingView *)release_rating_view didPressedVote:(NSInteger)vote {
    // TODO: add UI response, add remove vote action
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().release_vote(self->_release->id, static_cast<int32_t>(vote));
        return YES;
    } withUICompletion:^{
        
    }];
}

-(void)didShowAllPressedForReleaseVideoBlocksView:(ReleaseVideoBlocksView *)release_video_blocks {
    // TODO
}

-(void)releaseVideoBlocksView:(ReleaseVideoBlocksView *)release_video_blocks didSelectBanner:(anixart::ReleaseVideoBanner::Ptr)block {
    // TODO
}

-(void)releasePreviewView:(ReleasePreviewsView *)release_preview_view didSelectPreviewWithUrl:(NSURL *)url {
    // TODO
}

-(void)releaseRelatedView:(ReleaseRelatedView *)release_related__view didSelectRelease:(anixart::Release::Ptr)release {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithRelease:release] animated:YES];
}

-(void)didReplyPressedForCommentsTableView:(UITableView *)table_view comment:(anixart::Comment::Ptr)comment {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithReplyToComment:comment] animated:YES];
}

-(void)didShowAllPressedForReleaseCommentsView:(ReleaseCommentsView *)release_comments_view {
    CommentsTableViewController* comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->releases().release_comments(_release->id, 0, anixart::Comment::FilterBy::All)];
    comments_view_controller.delegate = self;
    [self.navigationController pushViewController:comments_view_controller animated:YES];
}

@end
