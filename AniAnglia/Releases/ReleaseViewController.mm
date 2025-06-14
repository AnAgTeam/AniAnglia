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
        [self setup];
        [self setupLayout];
    }
    else if (_release_getter) {
        [self loadWithReleaseGetter];
    } else {
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
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [_loading_view.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [_loading_view.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor]
    ]];

}

-(void)setup {
    __weak auto weak_self = self;
    _named_sections = [NSMutableArray arrayWithCapacity:5];
    
    self.navigationItem.title = TO_NSSTRING(_release->title_ru);
    
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
    [_add_list_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _bookmark_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_bookmark_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _play_button.backgroundColor = [AppColorProvider primaryColor];
    [_play_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _note_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)loadRelease {
    if (!_refresh_control.refreshing) {
        [_loading_view startLoading];
    }
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_release = self->_api_proxy.api->releases().get_release(self->_release_id);
        return NO;
    } completion:^(BOOL errored) {
        [self onReleaseLoaded:errored];
    }];
}

-(void)loadWithReleaseGetter {
    [_loading_view startLoading];
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_release = self->_release_getter(api);
        return NO;
    } completion:^(BOOL errored) {
        [self onReleaseLoaded:errored];
    }];
}

-(void)refresh {
    _title_label.text = TO_NSSTRING(_release->title_ru);
    _orig_title_label.text = TO_NSSTRING(_release->title_original);
    
    [self updateAddListButton];
    
    [_bookmark_button setTitle:[@(_release->favorite_count) stringValue] forState:UIControlStateNormal];
    [self updateBookmarkButton];
    
    _note_label.text = [HTMLStyleFormatter stringFromString:TO_NSSTRING(_release->note)];
    
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
    // TODO
}

-(void)onRelatedShowAllPressed {
    ReleaseRelatedViewController* view_controller = [[ReleaseRelatedViewController alloc] initWithPages:_api_proxy.api->releases().release_related(_release->related->id, 0)];
    [self.navigationController pushViewController:view_controller animated:YES];
}

-(void)onCommentsShowAllPresed {
    CommentsTableViewController* view_controller = [[CommentsTableViewController alloc] initWithTableView:[UITableView new] pages:_api_proxy.api->releases().release_comments(_release->id, 0, anixart::Comment::FilterBy::All)];
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

-(IBAction)onRefresh:(UIRefreshControl*)refresh_control {
    [self loadRelease];
}

-(void)didReloadForLoadableView:(LoadableView*)loadable_view {
    [self loadRelease];
}

@end
