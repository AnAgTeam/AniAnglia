//
//  ReleaseViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 29.08.2024.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
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
#import "ExpandableLabel.h"
#import "ReleasesTableViewController.h"
#import "NamedSectionView.h"
#import "ReleaseRelatedTableViewController.h"
#import "ReleasesViewController.h"

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
@end

@protocol ReleasePreviewViewDelegate <NSObject>
-(void)releasePreviewView:(ReleasePreviewsView*)release_preview_view didSelectPreviewWithUrl:(NSURL*)url;
@end

@protocol ReleaseRelatedViewDelegate <NSObject>
-(void)releaseRelatedView:(ReleaseRelatedView*)release_related__view didSelectRelease:(anixart::Release::Ptr)release;
@end

@interface ReleaseVoteIndicatorView : UIView
@property(nonatomic, retain, readonly) NSString* name;
@property(nonatomic, readonly) NSInteger vote_count;
@property(nonatomic, readonly) NSInteger vote_total_count;
@property(nonatomic, retain) UILabel* vote_number_label;
@property(nonatomic, retain) UIView* blank_indicator_view;
@property(nonatomic, retain) UIView* filled_indicator_view;
@property(nonatomic, retain) NSLayoutConstraint* filled_indicator_width;

-(instancetype)initWithName:(NSString*)name;
-(instancetype)initWithName:(NSString*)name voteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)total_vote_count;

-(void)setVoteCount:(NSInteger)vote_count totalVoteCount:(NSInteger)total_vote_count;
@end

@interface ReleaseNamedImageView : UIView
@property(nonatomic, retain, readonly) UIImage* image;
@property(nonatomic, retain, readonly) NSString* content;
@property(nonatomic, retain) UIImageView* image_view;
@property(nonatomic, retain) UILabel* content_label;

-(instancetype)initWithImage:(UIImage*)image;

-(void)setContent:(NSString*)content;

@end

@interface ReleaseVideoBlocksCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;

+(NSString*)getIdentifier;
-(instancetype)initWithFrame:(CGRect)frame;

-(void)setTitle:(NSString*)title;
-(void)setImageUrl:(NSURL*)image_url;
@end

@interface ReleaseVideoBlocksView : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, weak) id<ReleaseVideoBlocksViewDelegate> delegate;
@property(nonatomic, retain) UICollectionView* videos_collection_view;

-(instancetype)init;

-(void)setRelease:(anixart::Release::Ptr)release;

@end

@interface ReleaseRatingView : UIView {
    anixart::Release::Ptr _release;
}
@property(nonatomic, weak) id<ReleaseRatingViewDelegate> delegate;
@property(nonatomic, retain) UILabel* overall_label;
@property(nonatomic, retain) UILabel* total_votes_label;
@property(nonatomic, retain) UIStackView* votes_indicators_stack_view;
@property(nonatomic, retain) UIImageView* profile_image_view;
@property(nonatomic, retain) NSArray<ReleaseVoteIndicatorView*>* vote_indicators;
@property(nonatomic, retain) NSArray<UIButton*>* vote_buttons;
@property(nonatomic, retain) UIStackView* my_votes_stack_view;

-(instancetype)init;

-(void)setRelease:(anixart::Release::Ptr)release;

-(void)setErrored:(BOOL)errored;

@end

@interface ReleaseRelatedViewController : ReleasesViewController

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
@property(nonatomic, retain) UICollectionView* previews_collection_view;

-(instancetype)init;

-(void)setRelease:(anixart::Release::Ptr)release;

@end

@interface ReleaseEmbedCommentsViewController : CommentsTableViewController

@end

@interface ReleaseViewController () <ReleaseRatingViewDelegate, ReleaseVideoBlocksViewDelegate, ReleasePreviewViewDelegate, ReleaseRelatedViewDelegate, CommentsTableViewControllerDelegate, LoadableViewDelegate> {
    anixart::Release::Ptr _release;
}
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic) anixart::ReleaseID release_id;
@property(nonatomic) BOOL is_random_release;
@property(nonatomic) BOOL is_ui_inited;

@property(nonatomic, copy) anixart::Release::Ptr(^release_getter)(anixart::Api* api);

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
@property(nonatomic, retain) ExpandableLabel* description_label;

@property(nonatomic, retain) NSMutableArray<NamedSectionView*>* named_sections;
@property(nonatomic, retain) ReleaseRatingView* rating_view;
@property(nonatomic, retain) ProfileListsView* lists_view;
@property(nonatomic, retain) ReleaseVideoBlocksView* video_blocks_view;
@property(nonatomic, retain) ReleasePreviewsView* previews_view;
@property(nonatomic, retain) ReleaseRelatedTableViewController* related_view_controller;
@property(nonatomic, retain) CommentsTableViewController* comments_view_controller;

@property(nonatomic, retain) UIRefreshControl* refresh_control;

@end

@implementation ReleaseVoteIndicatorView

-(instancetype)initWithName:(NSString*)name {
    return [self initWithName:name voteCount:0 totalVoteCount:0];
}

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
    
    _blank_indicator_view = [UIView new];
    _blank_indicator_view.clipsToBounds = YES;
    
    _filled_indicator_view = [UIView new];
    
    [self addSubview:_vote_number_label];
    [self addSubview:_blank_indicator_view];
    [_blank_indicator_view addSubview:_filled_indicator_view];
    
    _vote_number_label.translatesAutoresizingMaskIntoConstraints = NO;
    _blank_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _filled_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _filled_indicator_width = [_filled_indicator_view.widthAnchor constraintEqualToAnchor:_blank_indicator_view.widthAnchor multiplier:(_vote_total_count > 0 ? static_cast<double>(_vote_count) / _vote_total_count : 0)];
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
    _filled_indicator_width = [_filled_indicator_view.widthAnchor constraintEqualToAnchor:_blank_indicator_view.widthAnchor multiplier:(_vote_total_count > 0 ? static_cast<double>(_vote_count) / _vote_total_count : 0)];
    _filled_indicator_width.active = YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _blank_indicator_view.layer.cornerRadius = _blank_indicator_view.frame.size.height / 2;
}
@end

@implementation ReleaseNamedImageView

-(instancetype)initWithImage:(UIImage*)image{
    self = [super init];
    
    _image = image;
    _content = nil;
    
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
        
        [_content_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_content_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_content_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_content_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}

-(void)setupLayout {
    _image_view.tintColor = [AppColorProvider textSecondaryColor];
    _content_label.textColor = [AppColorProvider textColor];
}

-(void)setContent:(NSString*)content {
    _content_label.text = content;
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

-(instancetype)init{
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _overall_label = [UILabel new];
    _overall_label.font = [UIFont systemFontOfSize:38];
    _overall_label.textAlignment = NSTextAlignmentCenter;
    
    _total_votes_label = [UILabel new];
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
        [[ReleaseVoteIndicatorView alloc] initWithName:@"5"],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"4"],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"3"],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"2"],
        [[ReleaseVoteIndicatorView alloc] initWithName:@"1"]
    ];
    
    _vote_buttons = @[
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton],
        [self makeVoteButton]
    ];
    
    [self addSubview:_overall_label];
    [self addSubview:_total_votes_label];
    [self addSubview:_votes_indicators_stack_view];
    [self addSubview:_my_votes_stack_view];
    for (ReleaseVoteIndicatorView* indicator_view : _vote_indicators) {
        [_votes_indicators_stack_view addArrangedSubview:indicator_view];
        
        indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
        [indicator_view.widthAnchor constraintEqualToAnchor:_votes_indicators_stack_view.widthAnchor].active = YES;
    }
    [_my_votes_stack_view addArrangedSubview:[UIView new]];
    [_my_votes_stack_view addArrangedSubview:_profile_image_view];
    for (UIButton* vote_button : _vote_buttons) {
        [_my_votes_stack_view addArrangedSubview:vote_button];
    }
    [_my_votes_stack_view addArrangedSubview:[UIView new]];
    
    _overall_label.translatesAutoresizingMaskIntoConstraints = NO;
    _total_votes_label.translatesAutoresizingMaskIntoConstraints = NO;
    _votes_indicators_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _my_votes_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _profile_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_overall_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
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
        
        [_profile_image_view.widthAnchor constraintEqualToAnchor:_my_votes_stack_view.heightAnchor],
        [_profile_image_view.heightAnchor constraintEqualToAnchor:_my_votes_stack_view.heightAnchor],
        
        [_my_votes_stack_view.topAnchor constraintEqualToAnchor:_votes_indicators_stack_view.bottomAnchor constant:5],
        [_my_votes_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_my_votes_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_my_votes_stack_view.heightAnchor constraintEqualToConstant:40],
        [_my_votes_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _overall_label.textColor = [AppColorProvider textColor];
    _total_votes_label.textColor = [AppColorProvider textSecondaryColor];
    _profile_image_view.backgroundColor = [AppColorProvider foregroundColor1];
}

-(UIButton*)makeVoteButton {
    UIButton* vote_button = [UIButton new];
    [vote_button setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [vote_button addTarget:self action:@selector(onSomeVoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    vote_button.tintColor = [AppColorProvider primaryColor];
    return vote_button;
}

-(IBAction)onSomeVoteButtonPressed:(UIButton*)vote_button {
    NSInteger index = [_vote_buttons indexOfObject:vote_button];
    if (index != NSNotFound) {
        [_delegate releaseRatingView:self didPressedVote:index + 1];
    }
}

-(void)updateInfo {
    if (!_release) {
        return;
    }
    
    // TODO: maybe assert
    [_vote_indicators[0] setVoteCount:_release->vote5_count totalVoteCount:_release->vote_count];
    [_vote_indicators[1] setVoteCount:_release->vote4_count totalVoteCount:_release->vote_count];
    [_vote_indicators[2] setVoteCount:_release->vote3_count totalVoteCount:_release->vote_count];
    [_vote_indicators[3] setVoteCount:_release->vote2_count totalVoteCount:_release->vote_count];
    [_vote_indicators[4] setVoteCount:_release->vote1_count totalVoteCount:_release->vote_count];
    
    _total_votes_label.text = [NSString stringWithFormat:@"%d %@", _release->vote_count, NSLocalizedString(@"app.release.rating.vote_count.end", "")];
    _overall_label.text = [@(round(_release->grade * 10) / 10) stringValue];
    
    for (UIButton* vote_button : _vote_buttons) {
        if ([_vote_buttons indexOfObject:vote_button] < _release->your_vote) {
            [vote_button setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
        } else {
            [vote_button setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
        }
    }
}

-(void)setRelease:(anixart::Release::Ptr)release {
    _release = release;
    [self updateInfo];
}

-(void)setErrored:(BOOL)errored {
    for (UIButton* vote_button : _vote_buttons) {
        vote_button.tintColor = !errored ? [AppColorProvider primaryColor] : [AppColorProvider alertColor];
    }
}

@end

@implementation ReleaseVideoBlocksView

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _videos_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _videos_collection_view.dataSource = self;
    _videos_collection_view.delegate = self;
    [_videos_collection_view registerClass:ReleaseVideoBlocksCollectionViewCell.class forCellWithReuseIdentifier:[ReleaseVideoBlocksCollectionViewCell getIdentifier]];
//    _videos_collection_view.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_videos_collection_view];
    
    _videos_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_videos_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_videos_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_videos_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_videos_collection_view.heightAnchor constraintEqualToConstant:180],
        [_videos_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setRelease:(anixart::Release::Ptr)release {
    _release = release;
    [_videos_collection_view reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!_release) {
        return 0;
    }
    return _release->video_banners.size();
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
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

@end

@implementation ReleaseRelatedViewController

-(UIViewController<PageableDataProviderDelegate>*)getTableViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider {
    return [[ReleaseRelatedTableViewController alloc] initWithTableView:[UITableView new] releasesPageableDataProvider:data_provider];
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

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    
    _previews_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_previews_collection_view registerClass:ReleasePreviewsCollectionViewCell.class forCellWithReuseIdentifier:[ReleasePreviewsCollectionViewCell getIdentifier]];
    _previews_collection_view.dataSource = self;
    _previews_collection_view.delegate = self;
    
    [self addSubview:_previews_collection_view];
    
    _previews_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_previews_collection_view.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_previews_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_previews_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_previews_collection_view.heightAnchor constraintEqualToConstant:180],
        [_previews_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setRelease:(anixart::Release::Ptr)release {
    _release = release;
    [_previews_collection_view reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!_release) {
        return 0;
    }
    return _release->screenshot_image_urls.size();
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
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

#pragma mark - AniLot: галерея изображений и список видео

#define AL(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

static UIViewController* AniLotTopController(UIViewController* from) {
    UIViewController* controller = from;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    return controller;
}

static void AniLotOpenExternalLink(UIViewController* from, NSString* string) {
    NSURL* url = [NSURL URLWithString:string];
    if (!url) {
        return;
    }
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        SFSafariViewController* safari = [[SFSafariViewController alloc] initWithURL:url];
        [AniLotTopController(from) presentViewController:safari animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

/* Одна страница галереи: изображение с зумом (щипок и двойное касание) */
@interface AniLotGalleryPageView : UIScrollView <UIScrollViewDelegate>
@property(nonatomic, strong) UIImageView* page_image_view;
@property(nonatomic, strong) UIActivityIndicatorView* page_spinner;
@property(nonatomic, strong) NSURL* page_url;
@property(nonatomic, readonly) UIImage* loaded_image;
-(void)loadIfNeeded;
@end

@implementation AniLotGalleryPageView

-(instancetype)initWithURL:(NSURL*)url {
    self = [super initWithFrame:CGRectZero];
    _page_url = url;
    self.delegate = self;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 4;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    _page_image_view = [UIImageView new];
    _page_image_view.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_page_image_view];
    
    _page_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _page_spinner.color = [AppColorProvider primaryColor];
    _page_spinner.hidesWhenStopped = YES;
    [self addSubview:_page_spinner];
    
    UITapGestureRecognizer* double_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    double_tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:double_tap];
    return self;
}

-(UIImage*)loaded_image {
    return _page_image_view.image;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _page_spinner.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (self.zoomScale == 1) {
        _page_image_view.frame = self.bounds;
    }
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView*)scroll_view {
    return _page_image_view;
}

-(void)scrollViewDidZoom:(UIScrollView*)scroll_view {
    CGFloat offset_x = MAX((scroll_view.bounds.size.width - scroll_view.contentSize.width) / 2, 0);
    CGFloat offset_y = MAX((scroll_view.bounds.size.height - scroll_view.contentSize.height) / 2, 0);
    _page_image_view.center = CGPointMake(scroll_view.contentSize.width / 2 + offset_x, scroll_view.contentSize.height / 2 + offset_y);
}

-(void)onDoubleTap:(UITapGestureRecognizer*)recognizer {
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
        return;
    }
    CGPoint point = [recognizer locationInView:_page_image_view];
    CGFloat scale = 2.5;
    CGSize size = CGSizeMake(self.bounds.size.width / scale, self.bounds.size.height / scale);
    [self zoomToRect:CGRectMake(point.x - size.width / 2, point.y - size.height / 2, size.width, size.height) animated:YES];
}

-(void)loadIfNeeded {
    if (_page_image_view.image || !_page_url) {
        return;
    }
    [_page_spinner startAnimating];
    __weak AniLotGalleryPageView* weak_self = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:_page_url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        UIImage* image = data ? [UIImage imageWithData:data] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            AniLotGalleryPageView* strong_self = weak_self;
            [strong_self.page_spinner stopAnimating];
            if (image) {
                strong_self.page_image_view.image = image;
            }
        });
    }] resume];
}

@end

/* Полноэкранная галерея: листание, зум, сохранение в «Фото» и «Поделиться» */
@interface AniLotGalleryViewController : UIViewController <UIScrollViewDelegate>
-(instancetype)initWithURLs:(NSArray<NSURL*>*)urls startIndex:(NSInteger)index;
@end

@implementation AniLotGalleryViewController {
    NSArray<NSURL*>* _urls;
    NSInteger _start_index;
    UIScrollView* _pager;
    NSMutableArray<AniLotGalleryPageView*>* _pages;
    UILabel* _counter_label;
    UILabel* _toast_label;
    UIView* _top_bar;
    BOOL _did_initial_scroll;
}

-(instancetype)initWithURLs:(NSArray<NSURL*>*)urls startIndex:(NSInteger)index {
    self = [super init];
    _urls = [urls copy];
    _start_index = MAX(0, MIN(index, (NSInteger)urls.count - 1));
    _pages = [NSMutableArray new];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _pager = [UIScrollView new];
    _pager.pagingEnabled = YES;
    _pager.delegate = self;
    _pager.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_pager];
    for (NSURL* url in _urls) {
        AniLotGalleryPageView* page = [[AniLotGalleryPageView alloc] initWithURL:url];
        [_pager addSubview:page];
        [_pages addObject:page];
    }
    
    _top_bar = [UIView new];
    _top_bar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_top_bar];
    
    UIButton* close_button = [UIButton buttonWithType:UIButtonTypeSystem];
    [close_button setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    close_button.tintColor = [AppColorProvider primaryColor];
    [close_button addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* download_button = [UIButton buttonWithType:UIButtonTypeSystem];
    [download_button setImage:[UIImage systemImageNamed:@"arrow.down.circle"] forState:UIControlStateNormal];
    download_button.tintColor = [AppColorProvider primaryColor];
    [download_button addTarget:self action:@selector(onDownload) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* share_button = [UIButton buttonWithType:UIButtonTypeSystem];
    [share_button setImage:[UIImage systemImageNamed:@"square.and.arrow.up"] forState:UIControlStateNormal];
    share_button.tintColor = [AppColorProvider primaryColor];
    [share_button addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
    
    _counter_label = [UILabel new];
    _counter_label.textColor = [UIColor whiteColor];
    _counter_label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _counter_label.textAlignment = NSTextAlignmentCenter;
    
    UIStackView* stack = [[UIStackView alloc] initWithArrangedSubviews:@[close_button, _counter_label, download_button, share_button]];
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 20;
    [_top_bar addSubview:stack];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    _top_bar.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_top_bar.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_top_bar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_top_bar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:6],
        [stack.bottomAnchor constraintEqualToAnchor:_top_bar.bottomAnchor constant:-6],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-16],
        [stack.heightAnchor constraintEqualToConstant:40]
    ]];
    
    _toast_label = [UILabel new];
    _toast_label.textColor = [UIColor whiteColor];
    _toast_label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _toast_label.textAlignment = NSTextAlignmentCenter;
    _toast_label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _toast_label.layer.cornerRadius = 12;
    _toast_label.layer.masksToBounds = YES;
    _toast_label.layer.borderWidth = 1;
    _toast_label.layer.borderColor = [AppColorProvider primaryColor].CGColor;
    _toast_label.alpha = 0;
    _toast_label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_toast_label];
    [NSLayoutConstraint activateConstraints:@[
        [_toast_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_toast_label.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-30],
        [_toast_label.heightAnchor constraintEqualToConstant:36],
        [_toast_label.widthAnchor constraintGreaterThanOrEqualToConstant:180]
    ]];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pager.frame = self.view.bounds;
    CGFloat width = _pager.bounds.size.width, height = _pager.bounds.size.height;
    _pager.contentSize = CGSizeMake(width * _pages.count, height);
    for (NSUInteger i = 0; i < _pages.count; i++) {
        AniLotGalleryPageView* page = _pages[i];
        if (page.zoomScale == 1) {
            page.frame = CGRectMake(width * i, 0, width, height);
        }
    }
    if (!_did_initial_scroll && width > 0) {
        _did_initial_scroll = YES;
        [_pager setContentOffset:CGPointMake(width * _start_index, 0) animated:NO];
        [self updateCurrentPage];
    }
}

-(NSInteger)currentIndex {
    CGFloat width = _pager.bounds.size.width;
    if (width <= 0) {
        return 0;
    }
    return MAX(0, MIN((NSInteger)llround(_pager.contentOffset.x / width), (NSInteger)_pages.count - 1));
}

-(void)updateCurrentPage {
    NSInteger index = [self currentIndex];
    _counter_label.text = [NSString stringWithFormat:@"%ld / %lu", (long)index + 1, (unsigned long)_pages.count];
    for (NSInteger i = index - 1; i <= index + 1; i++) {
        if (i >= 0 && i < (NSInteger)_pages.count) {
            [_pages[i] loadIfNeeded];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView*)scroll_view {
    if (scroll_view == _pager) {
        [self updateCurrentPage];
    }
}

-(void)showToast:(NSString*)text {
    _toast_label.text = [NSString stringWithFormat:@"  %@  ", text];
    [UIView animateWithDuration:0.2 animations:^{
        self->_toast_label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.6 options:0 animations:^{
            self->_toast_label.alpha = 0;
        } completion:nil];
    }];
}

-(void)onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onDownload {
    UIImage* image = _pages[[self currentIndex]].loaded_image;
    if (!image) {
        [self showToast:AL(@"app.gallery.not_loaded", @"Изображение ещё загружается")];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

-(void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)context_info {
    [self showToast:error ? AL(@"app.gallery.save_error", @"Не удалось сохранить (нет доступа к Фото)") : AL(@"app.gallery.saved", @"Сохранено в Фото")];
}

-(void)onShare:(UIButton*)sender {
    UIImage* image = _pages[[self currentIndex]].loaded_image;
    if (!image) {
        [self showToast:AL(@"app.gallery.not_loaded", @"Изображение ещё загружается")];
        return;
    }
    UIActivityViewController* sheet = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    sheet.popoverPresentationController.sourceView = sender;
    [self presentViewController:sheet animated:YES completion:nil];
}

@end

static void AniLotShowGallery(UIViewController* from, NSArray<NSURL*>* urls, NSInteger index) {
    if (urls.count == 0) {
        return;
    }
    AniLotGalleryViewController* gallery = [[AniLotGalleryViewController alloc] initWithURLs:urls startIndex:index];
    [AniLotTopController(from) presentViewController:gallery animated:YES completion:nil];
}

/* Ячейка видео: превью + название + площадка */
@interface AniLotVideoCell : UITableViewCell
@property(nonatomic, strong) LoadableImageView* thumb_view;
@property(nonatomic, strong) UILabel* name_label;
@property(nonatomic, strong) UILabel* host_label;
@end

@implementation AniLotVideoCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    self.backgroundColor = [AppColorProvider foregroundColor1];
    
    _thumb_view = [LoadableImageView new];
    _thumb_view.contentMode = UIViewContentModeScaleAspectFill;
    _thumb_view.clipsToBounds = YES;
    _thumb_view.layer.cornerRadius = 8;
    _thumb_view.backgroundColor = [AppColorProvider foregroundColor2];
    
    _name_label = [UILabel new];
    _name_label.numberOfLines = 3;
    _name_label.textColor = [AppColorProvider textColor];
    _name_label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    
    _host_label = [UILabel new];
    _host_label.textColor = [AppColorProvider textSecondaryColor];
    _host_label.font = [UIFont systemFontOfSize:13];
    
    UIStackView* texts = [[UIStackView alloc] initWithArrangedSubviews:@[_name_label, _host_label]];
    texts.axis = UILayoutConstraintAxisVertical;
    texts.spacing = 4;
    [self.contentView addSubview:_thumb_view];
    [self.contentView addSubview:texts];
    _thumb_view.translatesAutoresizingMaskIntoConstraints = NO;
    texts.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_thumb_view.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_thumb_view.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [_thumb_view.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],
        [_thumb_view.widthAnchor constraintEqualToConstant:128],
        [_thumb_view.heightAnchor constraintEqualToConstant:72],
        [texts.leadingAnchor constraintEqualToAnchor:_thumb_view.trailingAnchor constant:12],
        [texts.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [texts.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
    ]];
    return self;
}
@end

/* Экран видео аниме: трейлеры, опенинги, эндинги, клипы и т.д., сгруппированы по категориям */
@interface AniLotReleaseVideosViewController : UITableViewController
-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id focusCategory:(NSString*)category_id;
@end

@implementation AniLotReleaseVideosViewController {
    anixart::ReleaseID _release_id;
    NSString* _focus_category;
    std::vector<anixart::ReleaseVideoBlock::Ptr> _blocks;
    UIActivityIndicatorView* _spinner;
    UILabel* _empty_label;
}

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id focusCategory:(NSString*)category_id {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    _release_id = release_id;
    _focus_category = [category_id copy];
    self.title = AL(@"app.release.videos.title", @"Видео");
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.separatorColor = [AppColorProvider textShyColor];
    [self.tableView registerClass:AniLotVideoCell.class forCellReuseIdentifier:@"AniLotVideoCell"];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _spinner.color = [AppColorProvider primaryColor];
    _spinner.hidesWhenStopped = YES;
    self.tableView.backgroundView = _spinner;
    [_spinner startAnimating];
    
    __weak AniLotReleaseVideosViewController* weak_self = self;
    __block std::vector<anixart::ReleaseVideoBlock::Ptr> blocks;
    anixart::ReleaseID release_id = _release_id;
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        blocks = api->releases().release_video_main(release_id);
        return NO;
    } completion:^(BOOL errored) {
        AniLotReleaseVideosViewController* strong_self = weak_self;
        if (!strong_self) {
            return;
        }
        [strong_self->_spinner stopAnimating];
        if (!errored) {
            strong_self->_blocks = blocks;
        }
        if (strong_self->_blocks.empty()) {
            UILabel* label = [UILabel new];
            label.text = errored ? AL(@"app.release.videos.error", @"Не удалось загрузить видео") : AL(@"app.release.videos.empty", @"Видео пока нет");
            label.textColor = [AppColorProvider textSecondaryColor];
            label.textAlignment = NSTextAlignmentCenter;
            strong_self.tableView.backgroundView = label;
        }
        [strong_self.tableView reloadData];
        if (strong_self->_focus_category.length) {
            for (NSUInteger i = 0; i < strong_self->_blocks.size(); i++) {
                auto& block = strong_self->_blocks[i];
                if (block->category && [TO_NSSTRING(std::to_string(static_cast<int64_t>(block->category->id))) isEqualToString:strong_self->_focus_category] && block->videos.size()) {
                    [strong_self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
            }
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)table_view {
    return _blocks.size();
}
-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _blocks[section]->videos.size();
}
-(NSString*)tableView:(UITableView*)table_view titleForHeaderInSection:(NSInteger)section {
    auto& block = _blocks[section];
    return block->category ? TO_NSSTRING(block->category->name) : nil;
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    AniLotVideoCell* cell = [table_view dequeueReusableCellWithIdentifier:@"AniLotVideoCell" forIndexPath:index_path];
    anixart::ReleaseVideo::Ptr video = _blocks[index_path.section]->videos[index_path.row];
    cell.name_label.text = TO_NSSTRING(video->title);
    cell.host_label.text = video->hosting ? TO_NSSTRING(video->hosting->name) : @"";
    [cell.thumb_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(video->image_url)]];
    return cell;
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    anixart::ReleaseVideo::Ptr video = _blocks[index_path.section]->videos[index_path.row];
    NSString* link = TO_NSSTRING(video->url);
    if (link.length == 0) {
        link = TO_NSSTRING(video->player_url);
    }
    AniLotOpenExternalLink(self, link);
}

-(UIContextMenuConfiguration*)tableView:(UITableView*)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath*)index_path point:(CGPoint)point {
    anixart::ReleaseVideo::Ptr video = _blocks[index_path.section]->videos[index_path.row];
    NSString* link = TO_NSSTRING(video->url);
    NSMutableArray<NSURL*>* thumbs = [NSMutableArray new];
    NSInteger start = 0;
    for (NSUInteger i = 0; i < _blocks[index_path.section]->videos.size(); i++) {
        NSURL* thumb = [NSURL URLWithString:TO_NSSTRING(_blocks[index_path.section]->videos[i]->image_url)];
        if (thumb) {
            if ((NSInteger)i == index_path.row) {
                start = thumbs.count;
            }
            [thumbs addObject:thumb];
        }
    }
    __weak AniLotReleaseVideosViewController* weak_self = self;
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu*(NSArray<UIMenuElement*>* suggested) {
        return [UIMenu menuWithChildren:@[
            [UIAction actionWithTitle:AL(@"app.release.videos.open", @"Открыть видео") image:[UIImage systemImageNamed:@"play.rectangle"] identifier:nil handler:^(UIAction* action) {
                AniLotOpenExternalLink(weak_self, link);
            }],
            [UIAction actionWithTitle:AL(@"app.release.videos.preview", @"Превью (галерея)") image:[UIImage systemImageNamed:@"photo.on.rectangle"] identifier:nil handler:^(UIAction* action) {
                AniLotShowGallery(weak_self, thumbs, start);
            }],
            [UIAction actionWithTitle:AL(@"app.release.videos.copy", @"Скопировать ссылку") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
                [UIPasteboard generalPasteboard].string = link;
            }]
        ]];
    }];
}

@end

#pragma mark - AniLot: лента Anixart

static NSString* StripArticleMarkup(NSString* text) {
    if (text.length == 0) {
        return @"";
    }
    NSString* result = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    result = [result stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    result = [result stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    NSRegularExpression* tags = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:nil];
    result = [tags stringByReplacingMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    result = [result stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    result = [result stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    result = [result stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    result = [result stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/* Собирает текст поста и ссылки на картинки из блоков статьи */
static NSString* ArticleTextAndImages(anixart::Article::Ptr article, NSMutableArray<NSURL*>* images) {
    NSMutableArray<NSString*>* parts = [NSMutableArray new];
    if (!article || !article->payload) {
        return @"";
    }
    for (auto& block : article->payload->blocks) {
        if (auto paragraph = boost::get<anixart::ArticleParagraphBlock::Ptr>(&block)) {
            [parts addObject:StripArticleMarkup(TO_NSSTRING((*paragraph)->text))];
        } else if (auto header = boost::get<anixart::ArticleHeaderBlock::Ptr>(&block)) {
            [parts addObject:StripArticleMarkup(TO_NSSTRING((*header)->text))];
        } else if (auto list = boost::get<anixart::ArticleListBlock::Ptr>(&block)) {
            for (const std::string& item : (*list)->items) {
                [parts addObject:[@"• " stringByAppendingString:StripArticleMarkup(TO_NSSTRING(item))]];
            }
        } else if (auto quote = boost::get<anixart::ArticleQuoteBlock::Ptr>(&block)) {
            [parts addObject:[NSString stringWithFormat:@"«%@»", StripArticleMarkup(TO_NSSTRING((*quote)->text))]];
        } else if (auto media = boost::get<anixart::ArticleMediaBlock::Ptr>(&block)) {
            for (auto& file : (*media)->items) {
                NSURL* url = [NSURL URLWithString:TO_NSSTRING(file->url)];
                if (url) {
                    [images addObject:url];
                }
            }
        } else if (auto embed = boost::get<anixart::ArticleEmbedBlock::Ptr>(&block)) {
            NSURL* url = [NSURL URLWithString:TO_NSSTRING((*embed)->image_url)];
            if (url) {
                [images addObject:url];
            }
        }
    }
    NSMutableArray<NSString*>* non_empty = [NSMutableArray new];
    for (NSString* part in parts) {
        if (part.length) {
            [non_empty addObject:part];
        }
    }
    return [non_empty componentsJoinedByString:@"\n\n"];
}

@interface AniLotFeedCell : UITableViewCell
@property(nonatomic, strong) UILabel* header_label;
@property(nonatomic, strong) UILabel* text_label;
@property(nonatomic, strong) UILabel* footer_label;
@property(nonatomic, strong) LoadableImageView* media_view;
@property(nonatomic, strong) NSLayoutConstraint* media_height;
@end

@implementation AniLotFeedCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    self.backgroundColor = [AppColorProvider foregroundColor1];
    
    _header_label = [UILabel new];
    _header_label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _header_label.textColor = [AppColorProvider primaryColor];
    _header_label.numberOfLines = 2;
    
    _text_label = [UILabel new];
    _text_label.font = [UIFont systemFontOfSize:15];
    _text_label.textColor = [AppColorProvider textColor];
    _text_label.numberOfLines = 10;
    
    _media_view = [LoadableImageView new];
    _media_view.contentMode = UIViewContentModeScaleAspectFill;
    _media_view.clipsToBounds = YES;
    _media_view.layer.cornerRadius = 10;
    _media_view.backgroundColor = [AppColorProvider foregroundColor2];
    
    _footer_label = [UILabel new];
    _footer_label.font = [UIFont systemFontOfSize:13];
    _footer_label.textColor = [AppColorProvider textSecondaryColor];
    
    UIStackView* stack = [[UIStackView alloc] initWithArrangedSubviews:@[_header_label, _text_label, _media_view, _footer_label]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    [self.contentView addSubview:stack];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    _media_view.translatesAutoresizingMaskIntoConstraints = NO;
    _media_height = [_media_view.heightAnchor constraintEqualToConstant:190];
    _media_height.priority = UILayoutPriorityRequired - 1;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12],
        [stack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        _media_height
    ]];
    return self;
}
@end

@interface AniLotFeedViewController : UITableViewController
@end

@implementation AniLotFeedViewController {
    std::shared_ptr<anixart::Pageable<anixart::Article>> _pages;
    std::vector<anixart::Article::Ptr> _articles;
    BOOL _loading;
    BOOL _finished;
    BOOL _use_latest;
    UIActivityIndicatorView* _spinner;
}

-(instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    self.title = AL(@"app.feed.title", @"Лента");
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 260;
    [self.tableView registerClass:AniLotFeedCell.class forCellReuseIdentifier:@"AniLotFeedCell"];
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.tintColor = [AppColorProvider primaryColor];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _spinner.color = [AppColorProvider primaryColor];
    _spinner.hidesWhenStopped = YES;
    self.tableView.backgroundView = _spinner;
    [self reloadFeed];
}

-(void)onRefresh {
    [self reloadFeed];
}

-(void)reloadFeed {
    if (_loading) {
        [self.refreshControl endRefreshing];
        return;
    }
    _loading = YES;
    _finished = NO;
    _pages.reset();
    if (_articles.empty()) {
        [_spinner startAnimating];
    }
    __weak AniLotFeedViewController* weak_self = self;
    __block std::shared_ptr<anixart::Pageable<anixart::Article>> pages;
    __block std::vector<anixart::Article::Ptr> first;
    BOOL use_latest = _use_latest;
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        if (!use_latest) {
            try {
                anixart::requests::ArticlesFilterRequest request;
                request.channel_id = anixart::ChannelID(0);
                request.date_filter = anixart::requests::ArticlesFilterRequest::DateFilter::AllTime;
                pages = api->articles().get_articles(request, 0);
                first = pages->get();
            } catch (...) {
                first.clear();
            }
        }
        if (first.empty()) {
            pages = api->articles().get_latest_articles(0);
            first = pages->get();
        }
        return NO;
    } completion:^(BOOL errored) {
        AniLotFeedViewController* strong_self = weak_self;
        if (!strong_self) {
            return;
        }
        strong_self->_loading = NO;
        [strong_self->_spinner stopAnimating];
        [strong_self.refreshControl endRefreshing];
        if (!errored) {
            strong_self->_pages = pages;
            strong_self->_articles = first;
            strong_self->_finished = pages ? pages->is_end() : YES;
        }
        if (strong_self->_articles.empty()) {
            UILabel* label = [UILabel new];
            label.text = errored ? AL(@"app.feed.error", @"Не удалось загрузить ленту. Потяните вниз, чтобы повторить.") : AL(@"app.feed.empty", @"В ленте пока пусто");
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [AppColorProvider textSecondaryColor];
            strong_self.tableView.backgroundView = label;
        } else {
            strong_self.tableView.backgroundView = nil;
        }
        [strong_self.tableView reloadData];
    }];
}

-(void)loadMore {
    if (_loading || _finished || !_pages) {
        return;
    }
    _loading = YES;
    __weak AniLotFeedViewController* weak_self = self;
    __block std::vector<anixart::Article::Ptr> more;
    std::shared_ptr<anixart::Pageable<anixart::Article>> pages = _pages;
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        more = pages->next();
        return NO;
    } completion:^(BOOL errored) {
        AniLotFeedViewController* strong_self = weak_self;
        if (!strong_self) {
            return;
        }
        strong_self->_loading = NO;
        if (errored || more.empty()) {
            strong_self->_finished = YES;
            return;
        }
        strong_self->_finished = pages->is_end();
        NSUInteger start = strong_self->_articles.size();
        strong_self->_articles.insert(strong_self->_articles.end(), more.begin(), more.end());
        NSMutableArray<NSIndexPath*>* paths = [NSMutableArray new];
        for (NSUInteger i = 0; i < more.size(); i++) {
            [paths addObject:[NSIndexPath indexPathForRow:0 inSection:start + i]];
        }
        [strong_self.tableView performBatchUpdates:^{
            [strong_self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(start, more.size())] withRowAnimation:UITableViewRowAnimationNone];
        } completion:nil];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)table_view {
    return _articles.size();
}
-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    AniLotFeedCell* cell = [table_view dequeueReusableCellWithIdentifier:@"AniLotFeedCell" forIndexPath:index_path];
    anixart::Article::Ptr article = _articles[index_path.section];
    NSMutableArray<NSURL*>* images = [NSMutableArray new];
    NSString* text = ArticleTextAndImages(article, images);
    
    NSString* channel = article->channel ? TO_NSSTRING(article->channel->title) : @"";
    NSString* date_text = @"";
    NSDate* date = anix_time_point_to_nsdate(article->creation_date);
    if (date) {
        NSDateFormatter* formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        date_text = [formatter stringFromDate:date];
    }
    cell.header_label.text = channel.length ? [NSString stringWithFormat:@"%@ · %@", channel, date_text] : date_text;
    cell.text_label.text = text;
    cell.text_label.hidden = text.length == 0;
    if (images.count) {
        cell.media_view.hidden = NO;
        [cell.media_view tryLoadImageWithURL:images.firstObject];
    } else {
        cell.media_view.hidden = YES;
    }
    NSString* images_info = images.count > 1 ? [NSString stringWithFormat:@"  ·  %lu %@", (unsigned long)images.count, AL(@"app.feed.images", @"изображ.")] : @"";
    cell.footer_label.text = [NSString stringWithFormat:@"▲ %d%@", article->vote_count, images_info];
    
    if ((NSUInteger)index_path.section + 3 >= _articles.size()) {
        [self loadMore];
    }
    return cell;
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSMutableArray<NSURL*>* images = [NSMutableArray new];
    ArticleTextAndImages(_articles[index_path.section], images);
    AniLotShowGallery(self, images, 0);
}

@end

UIViewController* AniLotMakeFeedViewController(void) {
    return [AniLotFeedViewController new];
}

@implementation ReleaseViewController

-(instancetype)initWithRelease:(anixart::Release::Ptr)release {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release = release;
    _release_id = _release->id;
    _is_random_release = NO;
    _is_ui_inited = NO;
    
    return self;
}

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _release_id = release_id;
    _is_random_release = NO;
    _is_ui_inited = NO;
    
    return self;
}

-(instancetype)initWithRandomRelease {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _is_random_release = YES;
    _is_ui_inited = NO;
    _release_getter = ^(anixart::Api* api){
        return api->releases().random_release(false);
    };
    
    return self;
}

-(instancetype)initWithRandomCollectionRelease:(anixart::CollectionID)collection_id {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _is_random_release = YES;
    _is_ui_inited = NO;
    _release_getter = ^(anixart::Api* api){
        return api->releases().random_collection_release(collection_id, false);
    };
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    
    if (_release) {
        [self onReleaseLoaded:NO];
    }
    else {
        [self loadRelease];
    }
}

-(void)preSetup {
    _scroll_view = [UIScrollView new];
    
    _loading_view = [LoadableView new];
    _loading_view.delegate = self;
    
    _refresh_control = [UIRefreshControl new];
    [_refresh_control addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_scroll_view];
    [self.view addSubview:_loading_view];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loading_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_loading_view.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [_loading_view.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor]
    ]];

}

-(void)setup {
    __weak auto weak_self = self;
    _named_sections = [NSMutableArray arrayWithCapacity:5];
    
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 7;
    _content_stack_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 10, 0, 10);
    
    _release_image_view = [LoadableImageView new];
    _release_image_view.layer.cornerRadius = 13.0;
    _release_image_view.layer.masksToBounds = YES;
    _release_image_view.contentMode = UIViewContentModeScaleAspectFill;
    _release_image_view.userInteractionEnabled = YES;
    [_release_image_view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCoverTapped)]];

    _title_label = [UILabel new];
    _title_label.numberOfLines = 0;

    [_title_label setFont:[UIFont boldSystemFontOfSize:22]];
    
    _orig_title_label = [UILabel new];
    _orig_title_label.numberOfLines = 0;
    
    _actions_stack_view = [UIStackView new];
    _actions_stack_view.axis = UILayoutConstraintAxisHorizontal;
    _actions_stack_view.distribution = UIStackViewDistributionEqualCentering;
    _actions_stack_view.alignment = UIStackViewAlignmentFill;
    _actions_stack_view.layoutMargins = UIEdgeInsetsMake(8, 0, 8, 0);
    
    _add_list_button = [UIButton new];
    [_add_list_button setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
    [_add_list_button setMenu:[self makeAddListButtonMenu]];
    _add_list_button.showsMenuAsPrimaryAction = YES;
    _add_list_button.layer.cornerRadius = 8.0;
    _add_list_button.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    _bookmark_button = [UIButton new];
    [_bookmark_button addTarget:self action:@selector(onBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _bookmark_button.layer.cornerRadius = 8.0;
    _bookmark_button.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    _play_button = [UIButton new];
    [_play_button setTitle:NSLocalizedString(@"app.release.play_button.title", "") forState:UIControlStateNormal];
    _play_button.layer.cornerRadius = 9.0;
    [_play_button addTarget:self action:@selector(onPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _note_label = [UILabel new];
    _note_label.numberOfLines = 0;
    _note_label.textAlignment = NSTextAlignmentJustified;
    
    _info_stack_view = [UIStackView new];
    _info_stack_view.axis = UILayoutConstraintAxisVertical;
    _info_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _info_stack_view.alignment = UIStackViewAlignmentFill;
    
    _tags_label = [UILabel new];
    
    _prod_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"a.circle"]];
    _ep_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"rectangle.stack"]];
    _status_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"calendar"]];
    _author_info_view = [[ReleaseNamedImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.3"]];
    
    _description_label = [ExpandableLabel new];
    
    _rating_view = [ReleaseRatingView new];
    _rating_view.delegate = self;
    
    NamedSectionView* rating_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.rating", "") view:_rating_view];
    [_named_sections addObject:rating_section_view];
    
    _lists_view = [ProfileListsView new];
    
    NamedSectionView* lists_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.lists", "") view:_lists_view];
    [_named_sections addObject:lists_section_view];
    
    if (!_release->video_banners.empty()) {
        _video_blocks_view = [ReleaseVideoBlocksView new];
        _video_blocks_view.layoutMargins = UIEdgeInsetsZero;
        _video_blocks_view.delegate = self;
        
        NamedSectionView* video_blocks_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.video_blocks", "") view:_video_blocks_view];
        [video_blocks_section_view setShowAllButtonEnabled:YES];
        [video_blocks_section_view setShowAllHandler:^{
            [weak_self onVideoBlockShowAllPressed];
        }];
        [_named_sections addObject:video_blocks_section_view];
    }
    
    if (!_release->screenshot_image_urls.empty()) {
        _previews_view = [ReleasePreviewsView new];
        _previews_view.layoutMargins = UIEdgeInsetsZero;
        _previews_view.delegate = self;
        
        NamedSectionView* previews_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.previews", "") view:_previews_view];
        [_named_sections addObject:previews_section_view];
    }
    
    if (!_release->related_releases.empty()) {
        ReleasesPageableDataProvider* related_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_release->related_releases];
        _related_view_controller = [[ReleaseRelatedTableViewController alloc] initWithTableView:[DynamicTableView new] releasesPageableDataProvider:related_data_provider];
        _related_view_controller.is_container_view_controller = YES;
        [self addChildViewController:_related_view_controller];
        
        NamedSectionView* related_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.related", "") view:_related_view_controller.view];
        [related_section_view setShowAllButtonEnabled:YES];
        [related_section_view setShowAllHandler:^{
            [weak_self onRelatedShowAllPressed];
        }];
        [_named_sections addObject:related_section_view];
    }
    
    CommentsPageableDataProvider* comments_data_provider = [[CommentsPageableDataProvider alloc] initWithPages:nullptr initialComments:_release->comments];
    _comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[DynamicTableView new] dataProvider:comments_data_provider];
    [self addChildViewController:_comments_view_controller];
    _comments_view_controller.delegate = self;
    _comments_view_controller.is_container_view_controller = YES;
    
    NamedSectionView* comments_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.release.comments", "") view:_comments_view_controller.view];
    [comments_section_view setShowAllButtonEnabled:YES];
    [comments_section_view setShowAllHandler:^{
        [weak_self onCommentsShowAllPresed];
    }];
    [_named_sections addObject:comments_section_view];
    
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
    
    for (NamedSectionView* named_section : _named_sections) {
        [_content_stack_view addArrangedSubview:named_section];
        named_section.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
        
        named_section.translatesAutoresizingMaskIntoConstraints = NO;
        [named_section.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor].active = YES;
    }
    
    [self refresh];
    
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
    [NSLayoutConstraint activateConstraints:@[
        [_content_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_content_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor],
//        [_content_stack_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor], // wow, how this expand/collapse effect works??
        
        [_release_image_view.heightAnchor constraintEqualToConstant:340],
        [_release_image_view.widthAnchor constraintEqualToAnchor:_release_image_view.heightAnchor multiplier:(10. / 16)],
        
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
    ]];
    
    _is_ui_inited = YES;
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _release_image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _orig_title_label.textColor = [AppColorProvider textSecondaryColor];
    _add_list_button.backgroundColor = [AppColorProvider foregroundColor1];
    _add_list_button.tintColor = [AppColorProvider primaryColor];
    [_add_list_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _bookmark_button.backgroundColor = [AppColorProvider foregroundColor1];
    _bookmark_button.tintColor = [AppColorProvider primaryColor];
    [_bookmark_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _play_button.backgroundColor = [AppColorProvider primaryColor];
    [_play_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _note_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)loadRelease {
    if (!_refresh_control.refreshing) {
        [_loading_view startLoading];
    }
    
    if (_release_getter) {
        [self loadWithReleaseGetter];
        return;
    }
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_release = self->_api_proxy.api->releases().get_release(self->_release_id);
        return NO;
    } completion:^(BOOL errored) {
        [self onReleaseLoaded:errored];
    }];
}

-(void)loadWithReleaseGetter {
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_release = self->_release_getter(api);
        return NO;
    } completion:^(BOOL errored) {
        [self onReleaseLoaded:errored];
    }];
}

-(void)refresh {
    self.navigationItem.title = TO_NSSTRING(_release->title_ru);
    
    _title_label.text = TO_NSSTRING(_release->title_ru);
    _orig_title_label.text = TO_NSSTRING(_release->title_original);
    
    [self updateAddListButton];
    
    [_bookmark_button setTitle:[@(_release->favorite_count) stringValue] forState:UIControlStateNormal];
    [self updateBookmarkButton];
    
    NSString* note = TO_NSSTRING(_release->note);
//    NSData* note_data = [NSData dataWithBytes:_release->note.c_str() length:_release->note.size()];
//    NSData* note_data = [note dataUsingEncoding:NSUTF16StringEncoding];
//    _note_label.attributedText = [[NSAttributedString alloc] initWithData:note_data options:@{
//        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
//    } documentAttributes:nil error:nil];
    
    _note_label.text = [HTMLStyleFormatter stringFromString:note];
    
    NSString* ep_count = _release->episodes_total != 0 ? [@(_release->episodes_total) stringValue] : @"?";
    
    NSString* prod_info_content = [NSString stringWithFormat:@"%@, %@ %@ %@", TO_NSSTRING(_release->country), [ReleasesPageableDataProvider getSeasonNameFor:_release->season], TO_NSSTRING(_release->year), NSLocalizedString(@"app.release.general.year.end", "")];
    NSString* ep_info_content = [NSString stringWithFormat:@"%d/%@ %@ %ld %@", _release->episodes_released, ep_count, NSLocalizedString(@"app.release.general.ep_info.separator", ""), _release->duration.count(), NSLocalizedString(@"app.release.general.ep_info.end", "")];
    NSString* status_info_content = [NSString stringWithFormat:@"%@, %@%@", [ReleasesPageableDataProvider getCategoryNameFor:_release->category], [ReleasesPageableDataProvider getStatusNameFor:_release->status], [self makeAiredOnString]];
    NSString* author_info_content = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"app.release.general.author_info.studio", ""), TO_NSSTRING(_release->studio)];
    if (!_release->author.empty()) {
        author_info_content = [author_info_content stringByAppendingFormat:@"\n%@ %@", NSLocalizedString(@"app.release.general.author_info.author", ""), TO_NSSTRING(_release->author)];
    }
    if (!_release->director.empty()) {
        author_info_content = [author_info_content stringByAppendingFormat:@"\n%@ %@", NSLocalizedString(@"app.release.general.author_info.director", ""), TO_NSSTRING(_release->director)];
    }
    
    [_prod_info_view setContent:prod_info_content];
    [_ep_info_view setContent:ep_info_content];
    [_status_info_view setContent:status_info_content];
    [_author_info_view setContent:author_info_content];
    
    [_description_label setText:TO_NSSTRING(_release->description)];
    
    [_rating_view setRelease:_release];
    
    if (_lists_view) {
        [_lists_view setFromRelease:_release];
    }
    
    if (_video_blocks_view) {
        [_video_blocks_view setRelease:_release];
    }
    
    if (_previews_view) {
        [_previews_view setRelease:_release];
    }
    
    if (_related_view_controller) {
        ReleasesPageableDataProvider* related_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:nullptr initialReleases:_release->related_releases];
        [_related_view_controller setReleasesPageableDataProvider:related_data_provider];
    }
    
    if (_comments_view_controller) {
        CommentsPageableDataProvider* comments_data_provider = [[CommentsPageableDataProvider alloc] initWithPages:nullptr initialComments:_release->comments];
        [_comments_view_controller setDataProvider:comments_data_provider];
    }
    
    [_release_image_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(_release->image_url)]];
}

-(void)updateBookmarkButton {
    if (_release->is_favorite) {
        [_bookmark_button setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
    } else {
        [_bookmark_button setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
    }
}
-(void)updateAddListButton {
    [_add_list_button setTitle:[ProfileListsView getListStatusName:_release->profile_list_status] forState:UIControlStateNormal];
}

-(UIMenu*)makeAddListButtonMenu {
    return [UIMenu menuWithChildren:@[
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::NotWatching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::NotWatching];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Watching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Watching];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Plan] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Plan];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Watched] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Watched];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::HoldOn] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::HoldOn];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Dropped] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListMenuItemSelected:anixart::Profile::ListStatus::Dropped];
        }]
    ]];
}

-(NSString*)makeAiredOnString {
    if (_release->status != anixart::Release::Status::Ongoing) {
        return @"";
    }
    
    std::chrono::weekday weekday = _release->broadcast;
    if (weekday == std::chrono::Monday) {
        return NSLocalizedString(@"app.release.aired_on.monday", "");
    }
    if (weekday == std::chrono::Tuesday) {
        return NSLocalizedString(@"app.release.aired_on.tuesday", "");
    }
    if (weekday == std::chrono::Wednesday) {
        return NSLocalizedString(@"app.release.aired_on.wednesday", "");
    }
    if (weekday == std::chrono::Thursday) {
        return NSLocalizedString(@"app.release.aired_on.thursday", "");
    }
    if (weekday == std::chrono::Friday) {
        return NSLocalizedString(@"app.release.aired_on.friday", "");
    }
    if (weekday == std::chrono::Saturday) {
        return NSLocalizedString(@"app.release.aired_on.saturday", "");
    }
    if (weekday == std::chrono::Sunday) {
        return NSLocalizedString(@"app.release.aired_on.sunday", "");
    }
    return @"";
}

-(void)onReleaseLoaded:(BOOL)errored {
    [_loading_view endLoadingWithErrored:errored];
    if (_refresh_control.refreshing) {
        [_refresh_control endRefreshing];
    }
    
    _scroll_view.hidden = errored;
    if (errored) {
        _scroll_view.refreshControl = nil;
        return;
    }
    
    _scroll_view.refreshControl = _refresh_control;
    if (!_is_ui_inited) {
        [self setup];
        [self setupLayout];
    }
    [self refresh];
}

-(void)onAddListMenuItemSelected:(anixart::Profile::ListStatus)status {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().add_release_to_profile_list(self->_release->id, status);
        return YES;
    } withUICompletion:^{
        self->_release->profile_list_status = status;
        [self updateAddListButton];
    }];
}

-(IBAction)onPlayButtonPressed:(UIButton*)sender {
    [self.navigationController pushViewController:[[TypeSelectViewController alloc] initWithReleaseID:_release->id] animated:YES];
}
-(IBAction)onBookmarkButtonPressed:(UIButton*)sender {
    BOOL to_bookmark_on = !_release->is_favorite;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (to_bookmark_on) {
            api->releases().add_release_to_favorites(self->_release->id);
        } else {
            api->releases().remove_release_from_favorites(self->_release->id);
        }
        return YES;
    } withUICompletion:^{
        self->_release->is_favorite = to_bookmark_on;
        [self updateBookmarkButton];
    }];
}

-(void)onVideoBlockShowAllPressed {
    [self.navigationController pushViewController:[[AniLotReleaseVideosViewController alloc] initWithReleaseID:_release->id focusCategory:nil] animated:YES];
}

-(void)onRelatedShowAllPressed {
    ReleaseRelatedViewController* view_controller = [[ReleaseRelatedViewController alloc] initWithPages:_api_proxy.api->releases().release_related(_release->related->id, 0)];
    [self.navigationController pushViewController:view_controller animated:YES];
}

-(void)onCommentsShowAllPresed {
    CommentsTableViewController* view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->releases().release_comments(_release->id, 0, anixart::Comment::Sort::Newest)];
    view_controller.delegate = self;
    [self.navigationController pushViewController:view_controller animated:YES];
}

-(void)releaseRatingView:(ReleaseRatingView*)release_rating_view didPressedVote:(NSInteger)vote {
    BOOL is_vote_remove = _release->your_vote == vote;
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        if (is_vote_remove) {
            api->releases().delete_release_vote(self->_release->id);
        }
        else {
            api->releases().release_vote(self->_release->id, static_cast<int32_t>(vote));
        }
        return NO;
    } completion:^(BOOL errored) {
        [release_rating_view setErrored:errored];
        if (!errored) {
            // TODO: just refresh?
            self->_release->vote_count += !is_vote_remove ? +1 : -1;
            self->_release->your_vote = !is_vote_remove ? static_cast<int32_t>(vote) : 0;
            [release_rating_view setRelease:self->_release];
        }
    }];
}

-(void)releaseVideoBlocksView:(ReleaseVideoBlocksView *)release_video_blocks didSelectBanner:(anixart::ReleaseVideoBanner::Ptr)block {
    NSString* value = TO_NSSTRING(block->value);
    if (block->action_id == anixart::ReleaseVideoBanner::Action::Url && value.length) {
        AniLotOpenExternalLink(self, value);
        return;
    }
    [self.navigationController pushViewController:[[AniLotReleaseVideosViewController alloc] initWithReleaseID:_release->id focusCategory:(block->action_id == anixart::ReleaseVideoBanner::Action::VideoCategory ? value : nil)] animated:YES];
}

-(void)releasePreviewView:(ReleasePreviewsView *)release_preview_view didSelectPreviewWithUrl:(NSURL *)url {
    NSMutableArray<NSURL*>* urls = [NSMutableArray new];
    NSInteger start = 0;
    for (const std::string& screenshot : _release->screenshot_image_urls) {
        NSURL* screenshot_url = [NSURL URLWithString:TO_NSSTRING(screenshot)];
        if (!screenshot_url) {
            continue;
        }
        if ([screenshot_url isEqual:url]) {
            start = urls.count;
        }
        [urls addObject:screenshot_url];
    }
    AniLotShowGallery(self, urls, start);
}

-(void)onCoverTapped {
    NSURL* cover_url = [NSURL URLWithString:TO_NSSTRING(_release->image_url)];
    if (cover_url) {
        AniLotShowGallery(self, @[cover_url], 0);
    }
}

-(void)releaseRelatedView:(ReleaseRelatedView *)release_related__view didSelectRelease:(anixart::Release::Ptr)release {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithRelease:release] animated:YES];
}

-(void)didReplyPressedForCommentsTableView:(UITableView *)table_view comment:(anixart::Comment::Ptr)comment {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithReplyToComment:comment] animated:YES];
}

-(IBAction)onRefresh:(UIRefreshControl*)refresh_control {
    [self loadRelease];
}

-(void)didReloadForLoadableView:(LoadableView*)loadable_view {
    [self loadRelease];
}

@end
