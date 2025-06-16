//
//  CollectionsTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 16.04.2025.
//

#import <Foundation/Foundation.h>
#import "CollectionsCollectionViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "CollectionViewController.h"

@interface CollectionInfoBadge : UIView
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) UIImage* image;
@property(nonatomic, retain) UIImage* setted_image;
@property(nonatomic, retain) UIStackView* stack_view;
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIImageView* image_view;

-(instancetype)initWithName:(NSString*)name image:(UIImage*)image  settedImage:(UIImage*)setted_image;

-(void)setName:(NSString*)name;
-(void)setImage:(UIImage*)image;
@end

@interface CollectionCollectionViewCell ()
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) CollectionInfoBadge* comment_count_badge;
@property(nonatomic, retain) CollectionInfoBadge* bookmark_count_badge;
@property(nonatomic, retain) CAGradientLayer* gradient_layer;

@end

@interface CollectionsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, PageableDataProviderDelegate, LoadableViewDelegate>
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic) UICollectionViewScrollDirection axis;
@property(nonatomic, retain) CollectionsPageableDataProvider* data_provider;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UICollectionView* collection_view;
@property(nonatomic, retain) UIRefreshControl* refresh_control;
@property(nonatomic, retain) UILabel* empty_label;

@end

@implementation CollectionInfoBadge

-(instancetype)init {
    self = [super init];

    [self setup];
    [self setupLayout];
    
    return self;
}
-(instancetype)initWithName:(NSString*)name image:(UIImage*)image settedImage:(UIImage*)setted_image {
    self = [super init];
    
    _name = name;
    _image = image;
    _setted_image = setted_image;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    self.layer.cornerRadius = 8;
    
    _stack_view = [UIStackView new];
    _stack_view.axis = UILayoutConstraintAxisHorizontal;
    _stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _stack_view.alignment = UIStackViewAlignmentCenter;
    _stack_view.spacing = 5;
    
    _name_label = [UILabel new];
    _name_label.text = _name;
    
    _image_view = [[UIImageView alloc] initWithImage:_image];
    
    [self setIsSetted:NO];
    
    [self addSubview:_stack_view];
    [_stack_view addArrangedSubview:_name_label];
    [_stack_view addArrangedSubview:_image_view];
    
    _stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_stack_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_stack_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_stack_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_stack_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_name_label.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
//        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.7],
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [[AppColorProvider foregroundColor1] colorWithAlphaComponent:0.85];
    _name_label.textColor = [AppColorProvider textColor];
}

-(void)setName:(NSString*)name {
    _name = name;
    _name_label.text = name;
    [_name_label sizeToFit];
}
-(void)setImage:(UIImage*)image {
    _image = image;
    _image_view.image = image;
}

-(void)setIsSetted:(BOOL)is_setted {
    _image_view.image = is_setted ? _setted_image : _image;
    _image_view.tintColor = is_setted ? [AppColorProvider primaryColor] : [AppColorProvider textColor];
}

@end

@implementation CollectionCollectionViewCell

+(NSString*)getIdentifier {
    return @"CollectionCollectionViewCell";
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
    
    _title_label = [UILabel new];
    _title_label.numberOfLines = 2;
    _title_label.font = [UIFont systemFontOfSize:24];
    
    _comment_count_badge = [[CollectionInfoBadge alloc] initWithName:nil image:[UIImage systemImageNamed:@"message"] settedImage:[UIImage systemImageNamed:@"message.fill"]];
    _comment_count_badge.layoutMargins = UIEdgeInsetsMake(5, 8, 5, 8);
    
    _bookmark_count_badge = [[CollectionInfoBadge alloc] initWithName:nil image:[UIImage systemImageNamed:@"bookmark"] settedImage:[UIImage systemImageNamed:@"bookmark.fill"]];
    _bookmark_count_badge.layoutMargins = UIEdgeInsetsMake(5, 8, 5, 8);
    
    _gradient_layer = [CAGradientLayer layer];
    _gradient_layer.startPoint = CGPointMake(0, 0.3);
    _gradient_layer.endPoint = CGPointMake(0, 1);
    
    [self.layer addSublayer:_gradient_layer];
    self.backgroundView = _image_view;
    [self addSubview:_title_label];
    [self addSubview:_comment_count_badge];
    [self addSubview:_bookmark_count_badge];
    
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _comment_count_badge.translatesAutoresizingMaskIntoConstraints = NO;
    _bookmark_count_badge.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_title_label.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_title_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_comment_count_badge.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_comment_count_badge.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_comment_count_badge.heightAnchor constraintEqualToConstant:30],
        [_comment_count_badge.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_bookmark_count_badge.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_bookmark_count_badge.leadingAnchor constraintGreaterThanOrEqualToAnchor:_comment_count_badge.trailingAnchor constant:10],
        [_bookmark_count_badge.heightAnchor constraintEqualToConstant:30],
        [_bookmark_count_badge.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_bookmark_count_badge.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider foregroundColor1];
    _gradient_layer.colors = @[(id)[UIColor clearColor].CGColor, (id)[AppColorProvider backgroundColor].CGColor];
    _title_label.textColor = [AppColorProvider textColor];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _gradient_layer.frame = self.bounds;
}
-(void)traitCollectionDidChange:(UITraitCollection *)previous_trait_collection {
    _gradient_layer.colors = @[(id)[UIColor clearColor].CGColor, (id)[AppColorProvider backgroundColor].CGColor];
}

-(void)setImageUrl:(NSURL*)image_url {
    [_image_view tryLoadImageWithURL:image_url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setCommentCount:(NSInteger)comment_count {
    [_comment_count_badge setName:[@(comment_count) stringValue]];
}
-(void)setBookmarkCount:(NSInteger)bookmark_count {
    [_bookmark_count_badge setName:[@(bookmark_count) stringValue]];
}

-(void)setIsBookmarked:(BOOL)is_bookmarked {
    [_bookmark_count_badge setIsSetted:is_bookmarked];
}

@end

@implementation CollectionsCollectionViewController

-(instancetype)initWithAxis:(UICollectionViewScrollDirection)axis {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _axis = axis;
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages axis:(UICollectionViewScrollDirection)axis {
    self = [self initWithAxis:axis];

    _data_provider = [[CollectionsPageableDataProvider alloc] initWithPages:std::move(pages)];
    _data_provider.delegate = self;
    
    return self;
}

-(instancetype)initWithPageableDataProvier:(CollectionsPageableDataProvider*)pageable_data_provider axis:(UICollectionViewScrollDirection)axis {
    self = [self initWithAxis:axis];

    _data_provider = pageable_data_provider;
    _data_provider.delegate = self;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    if (_data_provider) {
        [_loadable_view startLoading];
        [_data_provider loadCurrentPageIfNeeded];
    }
}

-(void)setup {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = _axis;
    layout.minimumLineSpacing = 20;
    layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    
    _collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collection_view registerClass:CollectionCollectionViewCell.class forCellWithReuseIdentifier:[CollectionCollectionViewCell getIdentifier]];
    _collection_view.dataSource = self;
    _collection_view.delegate = self;
    _collection_view.prefetchDataSource = self;
    
    if (_axis != UICollectionViewScrollDirectionHorizontal) {
        _refresh_control = [UIRefreshControl new];
        [_refresh_control addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    }
    
    _loadable_view = [LoadableView new];
    _loadable_view.delegate = self;
    
    _empty_label = [UILabel new];
    _empty_label.text = NSLocalizedString(@"app.common.load_empty", "");
    _empty_label.hidden = YES;
    
    [self.view addSubview:_collection_view];
    [self.view addSubview:_loadable_view];
    [self.view addSubview:_empty_label];
    
    _collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_collection_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_collection_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_collection_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_collection_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [_collection_view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
        [_collection_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [_empty_label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_empty_label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setHeaderView:(UIView*)header_view {
    // TODO
}

-(void)setPages:(anixart::Pageable<anixart::Collection>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}

-(void)setDataProvider:(CollectionsPageableDataProvider*)pageable_data_provider {
    _data_provider = pageable_data_provider;
    if (_data_provider) {
        _data_provider.delegate = self;
        [_data_provider loadCurrentPageIfNeeded];
    }
}

-(void)reload {
    [_data_provider reload];
}

-(void)refresh {
    [_data_provider refresh];
}

-(void)collectionView:(UICollectionView*)collection_view prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *>*)index_paths {
    if (!_data_provider) {
        return;
    }
    if ([_data_provider isEnd]) {
        return;
    }
    NSUInteger item_count = [_collection_view numberOfItemsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [_data_provider loadNextPage];
            return;
        }
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collection_view numberOfItemsInSection:(NSInteger)section {
    if (!_data_provider) {
        return 0;
    }
    return [_data_provider getItemsCount];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    CollectionCollectionViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[CollectionCollectionViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = index_path.row;
    anixart::Collection::Ptr collection = [_data_provider getCollectionAtIndex:index];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(collection->image_url)];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(collection->title)];
    [cell setCommentCount:collection->comment_count];
    [cell setBookmarkCount:collection->favorite_count];
    [cell setIsBookmarked:collection->is_favorite];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewFlowLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    if (_axis == UICollectionViewScrollDirectionHorizontal) {
        return CGSizeMake(collection_view.frame.size.height * (16. / 9), collection_view.frame.size.height);
    }
    
    CGFloat width_inset = collection_view_layout.sectionInset.left + collection_view_layout.sectionInset.right;
    return CGSizeMake(collection_view.frame.size.width - width_inset, (collection_view.frame.size.width - width_inset) * (9. / 16));
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    anixart::Collection::Ptr collection = [_data_provider getCollectionAtIndex:index];
    
    [self.navigationController pushViewController:[[CollectionViewController alloc] initWithCollectionID:collection->id] animated:YES];
}

-(UIContextMenuConfiguration*)collectionView:(UICollectionView *)collection_view contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    NSInteger index = index_path.row;
    return [_data_provider getContextMenuConfigurationForItemAtIndex:index];
}

-(void)didUpdateDataForPageableDataProvider:(PageableDataProvider *)pageable_data_provide {
    [_collection_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadPageAtIndex:(NSInteger)page_index {
    [_loadable_view endLoading];
    _collection_view.refreshControl = _refresh_control;
    
    if (_refresh_control.refreshing) {
        [_refresh_control endRefreshing];
    }
    _empty_label.hidden = [_data_provider getItemsCount] != 0;
    [_collection_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider *)pageable_data_provider didFailPageAtIndex:(NSInteger)page_index {
    if (_refresh_control.refreshing) {
        [_data_provider clear];
        [_refresh_control endRefreshing];
        _collection_view.refreshControl = nil;	
    }
    [_loadable_view endLoadingWithErrored:YES];
}

-(IBAction)onRefresh:(UIRefreshControl*)sender {
    [self refresh];
}

-(void)didReloadForLoadableView:(LoadableView*)loadable_view {
    [_loadable_view startLoading];
    [self refresh];
}


@end
