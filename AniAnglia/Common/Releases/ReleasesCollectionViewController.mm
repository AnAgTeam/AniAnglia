//
//  ReleaseCollectionViewCell.m
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesCollectionViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "ReleaseTableViewCell.h"
#import "StringCvt.h"
#import "ReleaseViewController.h"

@interface ReleaseCollectionViewCell ()
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* episode_count_label;
@property(nonatomic, retain) UILabel* rating_badge_label;

@end

@interface ReleasesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout> {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    std::vector<anixart::Release::Ptr> _releases;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic) UICollectionViewScrollDirection axis;
@property(nonatomic) NSInteger axis_item_count;
@property(nonatomic, retain) NSLock* lock;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UICollectionView* collection_view;

@end

@implementation ReleaseCollectionViewCell

+(NSString*)getIdentifier {
    return @"ReleaseCollectionViewCell";
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 8;
    
    _title_label = [UILabel new];
    _title_label.numberOfLines = 2;
    
    _episode_count_label = [UILabel new];
    
    _rating_badge_label = [UILabel new];
    _rating_badge_label.clipsToBounds = YES;
    _rating_badge_label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_episode_count_label];
    [self addSubview:_rating_badge_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _episode_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_badge_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_rating_badge_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_rating_badge_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_rating_badge_label.trailingAnchor constraintEqualToAnchor:_image_view.trailingAnchor],
        [_rating_badge_label.widthAnchor constraintEqualToConstant:40],
        [_rating_badge_label.heightAnchor constraintEqualToConstant:40],
        [_rating_badge_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
        
        [_title_label.topAnchor constraintEqualToAnchor:_image_view.bottomAnchor constant:5],
        [_title_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_episode_count_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:5],
        [_episode_count_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_episode_count_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_episode_count_label.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
}
-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _episode_count_label.textColor = [AppColorProvider textSecondaryColor];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _rating_badge_label.layer.cornerRadius = _rating_badge_label.bounds.size.height / 2;
}

-(void)setImageUrl:(NSURL*)image_url {
    [_image_view tryLoadImageWithURL:image_url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setSetEpisodeCount:(NSString*)episode_count {
    _episode_count_label.text = episode_count;
}
-(void)setRating:(double)rating {
    _rating_badge_label.text = [@(round(rating * 10) / 10) stringValue];
    _rating_badge_label.backgroundColor = [ReleaseTableViewCell getBadgeColor:rating];
}
@end

@implementation ReleasesCollectionViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages axis:(UICollectionViewScrollDirection)axis {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _pages = std::move(pages);
    _axis = axis;
    _axis_item_count = 1;
    
    return self;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    [self loadFirstPage];
}
-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = _axis;
    _collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collection_view registerClass:ReleaseCollectionViewCell.class forCellWithReuseIdentifier:[ReleaseCollectionViewCell getIdentifier]];
    _collection_view.dataSource = self;
    _collection_view.delegate = self;
    _collection_view.prefetchDataSource = self;
    
    _loadable_view = [LoadableView new];
    
    [self.view addSubview:_collection_view];
    [self.view addSubview:_loadable_view];
    
    _collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    if (_is_container_view_controller) {
        [NSLayoutConstraint activateConstraints:@[
            [_collection_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_collection_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_collection_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_collection_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
            [_collection_view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
            [_collection_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    }
    else {
        [NSLayoutConstraint activateConstraints:@[
            [_collection_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_collection_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_collection_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_collection_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            
            [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
            [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor]
        ]];
    }
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setHeaderView:(UIView*)header_view {
    // TODO
}

-(void)appendItemsFromBlock:(std::vector<anixart::Release::Ptr>(^)())block {
    if (!_pages) {
        return;
    }
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        /* todo: change to thread-safe */
        auto new_items = block();
        [self->_lock lock];
        self->_releases.insert(self->_releases.end(), new_items.begin(), new_items.end());
        [self->_lock unlock];
        return YES;
    } withUICompletion:^{
        [self->_loadable_view endLoading];
        [self->_collection_view reloadData];
    }];
}

-(void)loadFirstPage {
    [_loadable_view startLoading];
    [self appendItemsFromBlock:^{
        return self->_pages->get();
    }];
}
-(void)loadNextPage {
    [self appendItemsFromBlock:^{
        return self->_pages->next();
    }];
}


-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    _pages = std::move(pages);
    [self reset];
    [self loadFirstPage];
}

-(void)reset {
    /* todo: load cancel */
    _releases.clear();
    [_collection_view reloadData];
}

-(void)setAxisItemCount:(NSInteger)axis_item_count {
    _axis_item_count = axis_item_count;
    [_collection_view reloadData];
}

-(void)collectionView:(UICollectionView*)collection_view prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *>*)index_paths {
    if (!_pages || _pages->is_end()) {
        return;
    }
    NSUInteger item_count = [_collection_view numberOfItemsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [self loadNextPage];
            return;
        }
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collection_view numberOfItemsInSection:(NSInteger)section {
    return _releases.size();
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    ReleaseCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[ReleaseCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = index_path.row;
    anixart::Release::Ptr& release = _releases[index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    NSString* episode_count = [NSString stringWithFormat:@"%d/%d %@", release->episodes_released, release->episodes_total, NSLocalizedString(@"app.release.episode_count.end", "")];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setSetEpisodeCount:episode_count];
    [cell setRating:release->grade];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewFlowLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    // TODO: maybe change aspect ratio
    if (_axis == UICollectionViewScrollDirectionHorizontal) {
        return CGSizeMake(collection_view.frame.size.height * (9. / 16), collection_view.frame.size.height);
    }
    
    CGFloat width_inset = collection_view_layout.sectionInset.left + collection_view_layout.sectionInset.right;
    CGFloat item_insets = collection_view_layout.minimumLineSpacing * (_axis_item_count - 1);
    CGFloat item_width = (collection_view.frame.size.width - width_inset - item_insets) / _axis_item_count;
    return CGSizeMake(item_width, item_width * (19. / 9));
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    anixart::Release::Ptr& release = _releases[index];
    
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}

@end
