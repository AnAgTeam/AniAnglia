//
//  DiscoverViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//"

#import <Foundation/Foundation.h>
#import "DiscoverViewController.h"
#import "ReleaseViewController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "AppColor.h"
#import "LoadableView.h"
#import "FilterViewController.h"
#import "CollectionsViewController.h"
#import "ReleasesCollectionViewController.h"
#import "CommentsTableViewController.h"
#import "DynamicTableView.h"
#import "CommentRepliesViewController.h"
#import "ReleasesTableViewController.h"
#import "SegmentedPageViewController.h"

@class DiscoverInterestingView;
@class DiscoverOptionsView;

@protocol DiscoverInterestingViewDelegate <NSObject>
-(void)discoverInterestingView:(DiscoverInterestingView*)interesting_view didSelectInteresting:(anixart::Interesting::Ptr)interesting;
@end

@protocol DiscoverOptionsViewDelegate
-(void)didPopularPressedForDiscoverOptionsView:(DiscoverOptionsView*)discover_options_view;
-(void)didSchedulePressedForDiscoverOptionsView:(DiscoverOptionsView*)discover_options_view;
-(void)didCollectionsPressedForDiscoverOptionsView:(DiscoverOptionsView*)discover_options_view;
-(void)didRandomPressedForDiscoverOptionsView:(DiscoverOptionsView*)discover_options_view;
@end

@interface DiscoverInterestingViewCell : UICollectionViewCell
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* description_label;
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) CAGradientLayer* gradient_layer;

+(NSString*)getIdentifier;
-(instancetype)initWithFrame:(CGRect)frame;

-(void)setImageUrl:(NSURL*)image_url;
-(void)setTitle:(NSString*)title;
-(void)setDescription:(NSString*)description;
@end

@interface DiscoverInterestingView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    std::vector<anixart::Interesting::Ptr> _interesting_arr;
}
@property(nonatomic, weak) id<DiscoverInterestingViewDelegate> delegate;
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UICollectionView* collection_view;
@property(nonatomic, retain) NSCache<NSNumber*, UIImage*>* image_cache;

-(instancetype)init;
@end

@interface DiscoverOptionsCollectionViewCell : UICollectionViewCell
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIImageView* image_view;

+(NSString*)getIdentifier;

-(void)setName:(NSString*)name;
-(void)setImage:(UIImage *)image;
@end

@interface DiscoverOptionsView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property(nonatomic, weak) id<DiscoverOptionsViewDelegate> delegate;
@property(nonatomic, retain) UICollectionView* options_collection_view;
@property(nonatomic, retain) NSLayoutConstraint* height_constraint;

-(instancetype)init;
@end

@interface DiscoverRecomendedView : UIView
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UITableView* table_view;

@end

@interface DiscoverDiscussingView : UIView
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIView* view;

-(instancetype)initWithView:(UIView*)view;
@end

@interface DiscoverWatchingView : UIView
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIView* view;

-(instancetype)initWithView:(UIView*)view;
@end

@interface DiscoverWeekCollectionsView : UIView
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIView* view;

-(instancetype)initWithView:(UIView*)view;
@end

@interface DiscoverWeekCommentsView : UIView
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIView* view;

-(instancetype)initWithView:(UIView*)view;
@end

@interface DiscoverViewController () <DiscoverInterestingViewDelegate, DiscoverOptionsViewDelegate, CommentsTableViewControllerDelegate>
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) UIStackView* content_stack_view;
@property(nonatomic, retain) DiscoverInterestingView* interesting_view;
@property(nonatomic, retain) DiscoverOptionsView* options_view;
@property(nonatomic, retain) DiscoverRecomendedView* recomended_view;
@property(nonatomic, retain) ReleasesTableViewController* discussing_table_view_controller;
@property(nonatomic, retain) DiscoverDiscussingView* discussing_view;
@property(nonatomic, retain) ReleasesCollectionViewController* watching_view_controller;
@property(nonatomic, retain) DiscoverWatchingView* watching_view;
@property(nonatomic, retain) CollectionsViewController* collections_view_controller;
@property(nonatomic, retain) DiscoverWeekCollectionsView* collections_view;
@property(nonatomic, retain) CommentsTableViewController* comments_view_controller;
@property(nonatomic, retain) DiscoverWeekCommentsView* comments_view;

@end

@implementation DiscoverInterestingViewCell

+(NSString*)getIdentifier {
    return @"DiscoverInterestingViewCell";
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    self.layer.cornerRadius = 12.0;
    self.layer.masksToBounds = YES;
    
    _gradient_layer = [CAGradientLayer layer];
    _gradient_layer.startPoint = CGPointMake(0, 0.3);
    _gradient_layer.endPoint = CGPointMake(0, 1);
    
    _image_view = [LoadableImageView new];

    _title_label = [UILabel new];
    [_title_label setFont:[UIFont boldSystemFontOfSize:_title_label.font.pointSize]];
    
    _description_label = [UILabel new];
    _description_label.numberOfLines = 2;
    
    [self.layer addSublayer:_gradient_layer];
    [self setBackgroundView:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_description_label];
    
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_title_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],

        [_description_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_description_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_description_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_description_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    _gradient_layer.colors = @[(id)[UIColor clearColor].CGColor, (id)[AppColorProvider backgroundColor].CGColor];
    _image_view.backgroundColor = [UIColor clearColor];
    _title_label.textColor = [AppColorProvider textColor];
    _description_label.textColor = [AppColorProvider textSecondaryColor];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _gradient_layer.frame = self.bounds;
}

-(void)traitCollectionDidChange:(UITraitCollection *)previous_trait_collection {
    [super traitCollectionDidChange:previous_trait_collection];
    [self setupLayout];
}

-(void)setImageUrl:(NSURL*)image_url {
    [_image_view tryLoadImageWithURL:image_url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
    [_title_label sizeToFit];
}
-(void)setDescription:(NSString*)description {
    _description_label.text = description;
    [_description_label sizeToFit];
}

@end

@implementation DiscoverInterestingView

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _image_cache = [NSCache new];
    [self preSetup];
    [self preSetupLayout];
    [self tryLoad];
    
    return self;
}

-(void)preSetup {
    _loadable_view = [LoadableView new];
    
    [self addSubview:_loadable_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_loadable_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_loadable_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_loadable_view.heightAnchor constraintEqualToConstant:200],
        [_loadable_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collection_view registerClass:DiscoverInterestingViewCell.class forCellWithReuseIdentifier:[DiscoverInterestingViewCell getIdentifier]];
    _collection_view.dataSource = self;
    _collection_view.delegate = self;
    _collection_view.showsHorizontalScrollIndicator = NO;

    [self addSubview:_collection_view];
    
    _collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)preSetupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)setupLayout {
    _collection_view.backgroundColor = [UIColor clearColor];
}

-(void)tryLoad {
    [_loadable_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        self->_interesting_arr = api->search().interesting()->get();
        return YES;
    } withUICompletion:^{
        [self->_loadable_view endLoading];
        [self setup];
        [self setupLayout];
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _interesting_arr.size();
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    DiscoverInterestingViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[DiscoverInterestingViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Interesting::Ptr& interesting = _interesting_arr[index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(interesting->image_url)];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(interesting->title)];
    [cell setDescription:TO_NSSTRING(interesting->description)];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.frame.size.height * (16. / 9), collection_view.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    anixart::Interesting::Ptr& interesting = _interesting_arr[index];
    
    [_delegate discoverInterestingView:self didSelectInteresting:interesting];
}

@end

@implementation DiscoverOptionsCollectionViewCell

+(NSString*)getIdentifier {
    return @"DiscoverOptionsCollectionViewCell";
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    _image_view = [UIImageView new];
    
    _name_label = [UILabel new];
    
    [self addSubview:_image_view];
    [self addSubview:_name_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.8],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.8],
        [_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_image_view.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_name_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_name_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_name_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider primaryColor];
    _image_view.tintColor = [AppColorProvider textColor];
    _name_label.textColor = [AppColorProvider textColor];
}

-(void)setName:(NSString *)name {
    _name_label.text = name;
    [_name_label sizeToFit];
}

-(void)setImage:(UIImage*)image {
    _image_view.image = image;
}

@end

@implementation DiscoverOptionsView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 12, 5, 12);
    layout.minimumLineSpacing = 18;
    _options_collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];;
    [_options_collection_view registerClass:DiscoverOptionsCollectionViewCell.class forCellWithReuseIdentifier:[DiscoverOptionsCollectionViewCell getIdentifier]];;
    _options_collection_view.dataSource = self;
    _options_collection_view.delegate = self;
    
    [self addSubview:_options_collection_view];
    
    _options_collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    _height_constraint = [_options_collection_view.heightAnchor constraintEqualToConstant:120];
    [NSLayoutConstraint activateConstraints:@[
        [_options_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_options_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_options_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        _height_constraint,
        [_options_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
    _options_collection_view.backgroundColor = [UIColor clearColor];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _height_constraint.constant = _options_collection_view.contentSize.height;
}

-(NSInteger)collectionView:(UICollectionView *)collection_view numberOfItemsInSection:(NSInteger)section {
    return 4;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.frame.size.width / 2 - 30, 50);
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    DiscoverOptionsCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[DiscoverOptionsCollectionViewCell getIdentifier] forIndexPath:index_path];
    
    switch (index) {
        case 0:
            [cell setName:NSLocalizedString(@"app.discover.option.popular.name", "")];
            [cell setImage:[UIImage systemImageNamed:@"flame"]];
            break;
        case 1:
            [cell setName:NSLocalizedString(@"app.discover.option.schedule.name", "")];
            [cell setImage:[UIImage systemImageNamed:@"calendar"]];
            break;
        case 2:
            [cell setName:NSLocalizedString(@"app.discover.option.collections.name", "")];
            [cell setImage:[UIImage systemImageNamed:@"rectangle.stack"]];
            break;
        case 3:
            [cell setName:NSLocalizedString(@"app.discover.option.random.name", "")];
            [cell setImage:[UIImage systemImageNamed:@"shuffle"]];
            break;
        default:
            [cell setName:nil];
            [cell setImage:nil];
    }

    return cell;
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    
    switch (index) {
        case 0:
            [self onPopularCellSelected];
            break;
        case 1:
            [self onScheduleCellSelected];
            break;
        case 2:
            [self onCollectionsCellSelected];
            break;
        case 3:
            [self onRandomCellSelected];
            break;
    }
}

-(void)onPopularCellSelected {
    [_delegate didPopularPressedForDiscoverOptionsView:self];
}
-(void)onScheduleCellSelected {
    [_delegate didSchedulePressedForDiscoverOptionsView:self];
}
-(void)onCollectionsCellSelected {
    [_delegate didCollectionsPressedForDiscoverOptionsView:self];
}
-(void)onRandomCellSelected {
    [_delegate didRandomPressedForDiscoverOptionsView:self];
}

@end

@implementation DiscoverRecomendedView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.discover.recomended.title", "");
    
    // TODO
    UILabel* _placeholder_label = [UILabel new];
    _placeholder_label.text = @"Птички летят, бомбить поросят";
    
    [self addSubview:_me_label];
    [self addSubview:_placeholder_label];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholder_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_me_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_placeholder_label.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_placeholder_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_placeholder_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_placeholder_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

@end

@implementation DiscoverDiscussingView

-(instancetype)initWithView:(UIView*)view {
    self = [super init];
    
    _view = view;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.discover.discussing.title", "");
    
    [self addSubview:_me_label];
    [self addSubview:_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_me_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    [_me_label sizeToFit];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}


@end

@implementation DiscoverWatchingView

-(instancetype)initWithView:(UIView*)view {
    self = [super init];
    
    _view = view;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.discover.watching.title", "");
    
    [self addSubview:_me_label];
    [self addSubview:_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.heightAnchor constraintEqualToConstant:250],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

@end

@implementation DiscoverWeekCollectionsView

-(instancetype)initWithView:(UIView*)view {
    self = [super init];
    
    _view = view;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.discover.week_collections.title", "");
    
    [self addSubview:_me_label];
    [self addSubview:_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.heightAnchor constraintEqualToConstant:200],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

@end

@implementation DiscoverWeekCommentsView

-(instancetype)initWithView:(UIView*)view {
    self = [super init];
    
    _view = view;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _me_label = [UILabel new];
    _me_label.font = [UIFont systemFontOfSize:22];
    _me_label.text = NSLocalizedString(@"app.discover.weak_comments.title", "");
    
    [self addSubview:_me_label];
    [self addSubview:_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    _me_label.textColor = [AppColorProvider textColor];
}

@end

@implementation DiscoverViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];

    [self setup];
    [self setupLayout];
}

-(void)setup {
    _scroll_view = [UIScrollView new];
    
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 7;
    _content_stack_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 10, 0, 10);
//    _content_stack_view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _interesting_view = [DiscoverInterestingView new];
    _interesting_view.delegate = self;
    
    _options_view = [DiscoverOptionsView new];
    _options_view.delegate = self;
    
    _recomended_view = [DiscoverRecomendedView new];
    _recomended_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _discussing_table_view_controller = [[ReleasesTableViewController alloc] initWithTableView:[DynamicTableView new] pages:_api_proxy.api->search().discussing()];
    _discussing_table_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_discussing_table_view_controller];
    
    _discussing_view = [[DiscoverDiscussingView alloc] initWithView:_discussing_table_view_controller.view];
    _discussing_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _watching_view_controller = [[ReleasesCollectionViewController alloc] initWithPages:_api_proxy.api->search().currently_watching(0) axis:UICollectionViewScrollDirectionHorizontal];
    _watching_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_watching_view_controller];
    
    _watching_view = [[DiscoverWatchingView alloc] initWithView:_watching_view_controller.view];
    _watching_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _collections_view_controller = [[CollectionsViewController alloc] initWithPages:_api_proxy.api->collections().all_collections(anixart::Collection::Sort::WeekPopular, 2, 0) axis:UICollectionViewScrollDirectionHorizontal];
    _collections_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_collections_view_controller];
    
    _collections_view = [[DiscoverWeekCollectionsView alloc] initWithView:_collections_view_controller.view];
    _collections_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[DynamicTableView new] pages:_api_proxy.api->search().comments_week()];
    _comments_view_controller.enable_origin_reference = YES;
    _comments_view_controller.is_container_view_controller = YES;
    _comments_view_controller.delegate = self;
    [self addChildViewController:_comments_view_controller];
    
    _comments_view = [[DiscoverWeekCommentsView alloc] initWithView:_comments_view_controller.view];
    _comments_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);

    [self.view addSubview:_scroll_view];
    [_scroll_view addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_interesting_view];
    [_content_stack_view addArrangedSubview:_options_view];
    [_content_stack_view addArrangedSubview:_recomended_view];
    [_content_stack_view addArrangedSubview:_discussing_view];
    [_content_stack_view addArrangedSubview:_watching_view];
    [_content_stack_view addArrangedSubview:_collections_view];
    [_content_stack_view addArrangedSubview:_comments_view];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _interesting_view.translatesAutoresizingMaskIntoConstraints = NO;
    _options_view.translatesAutoresizingMaskIntoConstraints = NO;
    _recomended_view.translatesAutoresizingMaskIntoConstraints = NO;
    _discussing_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watching_view.translatesAutoresizingMaskIntoConstraints = NO;
    _collections_view.translatesAutoresizingMaskIntoConstraints = NO;
    _comments_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [_content_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_content_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor],
        
        [_interesting_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_options_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_recomended_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_discussing_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_watching_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_collections_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_comments_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor]
    ]];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(IBAction)onFilterBarButtonPressed:(UIBarButtonItem*)sender {
    [self.navigationController pushViewController:[FilterViewController new] animated:YES];
}

-(void)didPopularPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
//    anixart::requests::FilterRequest fr;
//    fr.sort = anixart::requests::FilterRequest::Sort::DateUpdate;
//    SegmentedPageViewController* page_view_controller = [SegmentedPageViewController new];
//    [page_view_controller setPageViewControllers:@[
//        [ReleasesTableViewController alloc] initWithPages:],
//    ]];
}
-(void)didSchedulePressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    // TODO
}
-(void)didCollectionsPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController pushViewController:[[CollectionsViewController alloc] initWithPages:_api_proxy.api->collections().all_collections(anixart::Collection::Sort::RecentlyAdded, 1, 0) axis:UICollectionViewScrollDirectionVertical] animated:YES];
}
-(void)didRandomPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithRandomRelease] animated:YES];
}

-(void)discoverInterestingView:(DiscoverInterestingView *)interesting_view didSelectInteresting:(anixart::Interesting::Ptr)interesting { 
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.hidesBarsOnSwipe = NO;
    if (interesting->type == anixart::Interesting::Type::OpenRelease) {
        [self.navigationController setNavigationBarHidden:NO];
        anixart::ReleaseID release_id = static_cast<anixart::ReleaseID>(std::stoll(interesting->action));
        [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release_id] animated:YES];
    }
}

-(void)didReplyPressedForCommentsTableView:(UITableView *)table_view comment:(anixart::Comment::Ptr)comment {
    [self.navigationController pushViewController:[[CommentRepliesViewController alloc] initWithReplyToComment:comment] animated:YES];
}

@end
