//
//  DiscoverViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "DiscoverViewController.h"
#import "ReleaseViewController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "AppColor.h"
#import "AppSearchController.h"
#import "SearchReleasesView.h"
#import "ReleasesSearchHistoryView.h"

@interface InterestingViewCell : UICollectionViewCell
@property(nonatomic, retain) UILabel* title;
@property(nonatomic, retain) UILabel* desc;
@property(nonatomic, retain) UIImageView* image_view;

+(NSString*)getIndentifier;
-(instancetype)initWithFrame:(CGRect)frame;
@end

@interface InterestingView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, retain) UIActivityIndicatorView* activity_ind;
@property(nonatomic, retain) UICollectionView* collection_view;
@property(nonatomic) std::vector<libanixart::Interesting::Ptr> interest_arr;
@property(nonatomic, retain) NSCache<NSNumber*, UIImage*>* image_cache;
@property(nonatomic, retain) DiscoverViewController* delegate;

-(instancetype)initWithDelegate:(DiscoverViewController*)delegate;
-(void)tryLoad;
-(CGFloat)getTotalHeight;
@end

@interface DiscoverOptionsTableViewCell : UITableViewCell
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) UIImage* image;
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIImageView* image_view;
@property(nonatomic) SEL callback_sel;

-(instancetype)initWithName:(NSString*)name image:(UIImage*)image callback:(SEL)callback;
+(instancetype)cellWithName:(NSString*)name image:(UIImage*)image callback:(SEL)callback;
@end

@protocol DiscoverOptionsTableViewDelegate
-(void)popularButtonPressed;
-(void)scheduleButtonPressed;
-(void)collectionsButtonPressed;
-(void)filterButtonPressed;
-(void)randomButtonPressed;
@end

@interface DiscoverOptionsTableView : UITableView <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, retain) NSObject<DiscoverOptionsTableViewDelegate>* opt_delegate;
@property(nonatomic, retain) NSArray<DiscoverOptionsTableViewCell*>* option_cells;

-(instancetype)initWithDelegate:(id<DiscoverOptionsTableViewDelegate>)delegate;
-(CGFloat)getTotalHeight;
@end

@interface DiscoverViewController () <DiscoverOptionsTableViewDelegate, SearchReleasesViewDataSource, SearchReleasesViewDelegate>
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) UIView* content_view;
@property(nonatomic, retain) InterestingView* interesting_view;
@property(nonatomic, retain) DiscoverOptionsTableView* options_view;
@property(nonatomic) std::vector<libanixart::Release::Ptr> search_releases;
@property(nonatomic) std::shared_ptr<libanixart::ReleaseSearchPages> search_release_pages;

-(void)didSelectInterestingCell:(long long)release_id;
@end

@implementation InterestingViewCell

+(NSString*)getIndentifier {
    return @"InterestingViewCell";
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 12.0;
    self.layer.masksToBounds = YES;
    _image_view = [[UIImageView alloc] initWithFrame:frame];
    [self setBackgroundView:_image_view];
    _image_view.image = nil;
    _desc = [UILabel new];
    [self addSubview:_desc];
    [_desc.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-15.0].active = YES;
    [_desc.heightAnchor constraintLessThanOrEqualToConstant:50.0].active = YES;
    [_desc.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10.0].active = YES;
    [_desc.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5.0].active = YES;
    _desc.translatesAutoresizingMaskIntoConstraints = NO;
    _desc.numberOfLines = 2;
    _title = [UILabel new];
    [self addSubview:_title];
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    [_title.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-15.0].active = YES;
    [_title.heightAnchor constraintEqualToConstant:15.0].active = YES;
    [_title.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10.0].active = YES;
    [_title.bottomAnchor constraintEqualToAnchor:_desc.topAnchor constant:-2.0].active = YES;
    [_title setFont:[UIFont boldSystemFontOfSize:_title.font.pointSize]];
    _title.layer.shadowRadius = 2.2;
    _title.layer.shadowOffset = CGSizeMake(0, 0);
    _title.layer.shadowOpacity = 1.0;
    
    [self setupLayout];
    
    return self;
}

-(void)setupLayout {
    /*
      MAYBE CHANGE TO STATIC COLORS
     */
    _image_view.backgroundColor = [UIColor clearColor];
    _title.textColor = [AppColorProvider textColor];
    _title.shadowColor = [AppColorProvider backgroundColor];
    _desc.textColor = [AppColorProvider textSecondaryColor];
}

@end

@implementation InterestingView
static CGFloat INTERESTING_VIEW_SIZE = 220;
static CGFloat INTERESTING_VIEW_HOFFSET = 10;

-(instancetype)initWithDelegate:(DiscoverViewController*)delegate {
    self = [super init];
    
    _delegate = delegate;
    _image_cache = [NSCache new];
    _activity_ind = [UIActivityIndicatorView new];
    
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collection_view {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _interest_arr.size();
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collection_view cellForItemAtIndexPath:(NSIndexPath *)index_path {
    InterestingViewCell* cell = [collection_view dequeueReusableCellWithReuseIdentifier:[InterestingViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    cell.title.text = TO_NSSTRING(_interest_arr[index]->title);
    cell.desc.text = TO_NSSTRING(_interest_arr[index]->description);
    [cell.desc sizeToFit];
    UIImage* cached_image = [_image_cache objectForKey:[[NSNumber alloc] initWithLong:index]];
    if (cached_image) {
        cell.image_view.image = cached_image;
        return cell;
    }
    cell.image_view.image = nil;
    
    NSString* url_str = TO_NSSTRING(_interest_arr[index]->image_url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* url = [[NSURL alloc] initWithString:url_str];
        NSData* data = [NSData dataWithContentsOfURL:url];
        if (data == nil) {
            // error
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [UIImage imageWithData:data];
            cell.image_view.image = image;
            [self->_image_cache setObject:image forKey:[[NSNumber alloc] initWithLong:index]];
        });
    });
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collection_view layout:(UICollectionViewLayout *)collection_view_layout sizeForItemAtIndexPath:(NSIndexPath *)index_path {
    return CGSizeMake(collection_view.frame.size.height * 1.66, collection_view.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collection_view didSelectItemAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    [_delegate didSelectInterestingCell:std::stoll(_interest_arr[index]->action)];
}

-(void)tryLoad {
    LibanixartApi* api_proxy = [LibanixartApi sharedInstance];
    _activity_ind.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_activity_ind];
    
    [_activity_ind.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_activity_ind.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    [_activity_ind.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_activity_ind.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    _activity_ind.transform = CGAffineTransformMakeScale(2.5, 2.5);
    [_activity_ind startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            self->_interest_arr = api_proxy.api->search().interesting().get();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupCollectionView];
            });
        } catch(const libanixart::ApiError& e) {
                // error
        }
    });
}

-(void)setupCollectionView {
    [_activity_ind stopAnimating];
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_collection_view];
    [_collection_view.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-(INTERESTING_VIEW_HOFFSET * 2)].active = YES;
    [_collection_view.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_collection_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_collection_view.topAnchor constraintEqualToAnchor:self.topAnchor constant:INTERESTING_VIEW_HOFFSET].active = YES;
    [_collection_view registerClass:InterestingViewCell.class forCellWithReuseIdentifier:[InterestingViewCell getIndentifier]];
    [_collection_view setDelegate:self];
    [_collection_view setDataSource:self];
    _collection_view.showsHorizontalScrollIndicator = NO;
    
    [self setupLayout];
}

-(void)setupLayout {
    _collection_view.backgroundColor = [UIColor clearColor];
}

-(CGFloat)getTotalHeight {
    return INTERESTING_VIEW_SIZE;
}

@end

@implementation DiscoverOptionsTableViewCell

-(instancetype)initWithName:(NSString*)name image:(UIImage*)image callback:(SEL)callback_sel {
    self = [super init];
    
    _name = name;
    _image = image;
    _callback_sel = callback_sel;
    
    [self setupView];
    
    return self;
}

+(instancetype)cellWithName:(NSString*)name image:(UIImage*)image callback:(SEL)callback {
    return [[DiscoverOptionsTableViewCell alloc] initWithName:name image:image callback:callback];
}

-(void)setupView {
    _image_view = [UIImageView new];
    [self addSubview:_image_view];
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _image_view.image = _image;
    [_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;
    [_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_image_view.widthAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.6].active = YES;
    [_image_view.heightAnchor constraintEqualToAnchor:_image_view.widthAnchor].active = YES;
    
    _name_label = [UILabel new];
    [self addSubview:_name_label];
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.text = _name;
    [_name_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5].active = YES;
    [_name_label.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_name_label.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_name_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    
    [self setupLayout];
}

-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
    _image_view.tintColor = [AppColorProvider textColor];
    _name_label.textColor = [AppColorProvider textColor];
}

@end

@implementation DiscoverOptionsTableView
static CGFloat OPTIONS_CELL_HEIGHT = 65;

-(instancetype)initWithDelegate:(NSObject<DiscoverOptionsTableViewDelegate>*)delegate {
    self = [self init];
    
    _opt_delegate = delegate;
    self.delegate = self;
    self.dataSource = self;
    _option_cells = @[
        [DiscoverOptionsTableViewCell cellWithName:NSLocalizedString(@"app.discover.option.popular.name", "") image:[UIImage systemImageNamed:@"flame"] callback:@selector(popularButtonPressed)],
        [DiscoverOptionsTableViewCell cellWithName:NSLocalizedString(@"app.discover.option.schedule.name", "") image:[UIImage systemImageNamed:@"calendar"] callback:@selector(scheduleButtonPressed)],
        [DiscoverOptionsTableViewCell cellWithName:NSLocalizedString(@"app.discover.option.collections.name", "") image:[UIImage systemImageNamed:@"rectangle.stack"] callback:@selector(collectionsButtonPressed)],
        [DiscoverOptionsTableViewCell cellWithName:NSLocalizedString(@"app.discover.option.filter.name", "") image:[UIImage systemImageNamed:@"slider.horizontal.3"] callback:@selector(filterButtonPressed)],
        [DiscoverOptionsTableViewCell cellWithName:NSLocalizedString(@"app.discover.option.random.name", "") image:[UIImage systemImageNamed:@"shuffle"] callback:@selector(randomButtonPressed)]
    ];
    
    return self;
}

-(CGFloat)getTotalHeight {
    return OPTIONS_CELL_HEIGHT * [_option_cells count];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return  [_option_cells count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return OPTIONS_CELL_HEIGHT;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    return _option_cells[index];
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    [_opt_delegate methodForSelector:_option_cells[index].callback_sel]();
}

@end

@implementation DiscoverViewController

//-(void)loadView {
////    [super loadView];
//    
//    _scroll_view = [UIScrollView new];
//    self.view = _scroll_view;
//}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    self.inline_search_view = [ReleasesSearchHistoryView new];
    SearchReleasesView* search_releases_view = [SearchReleasesView new];
    search_releases_view.delegate = self;
    search_releases_view.data_source = self;
    self.search_view = search_releases_view;
    
    [self setupView];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO];
}

-(void)setupView {    
    _scroll_view = [UIScrollView new];
    [self.view addSubview:_scroll_view];
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_scroll_view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_scroll_view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_scroll_view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    _content_view = [UIView new];
    [_scroll_view addSubview:_content_view];
    _content_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_content_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor].active = YES;
    NSLayoutConstraint* hconst = [_content_view.heightAnchor constraintEqualToAnchor:_scroll_view.heightAnchor];
    hconst.active = YES;
    hconst.priority = UILayoutPriority(50);
    [_content_view.leftAnchor constraintEqualToAnchor:_scroll_view.leftAnchor].active = YES;
    [_content_view.rightAnchor constraintEqualToAnchor:_scroll_view.rightAnchor].active = YES;
    [_content_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor].active = YES;
    
    _interesting_view = [[InterestingView alloc] initWithDelegate:self];
    [_content_view addSubview:_interesting_view];
    _interesting_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_interesting_view.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor].active = YES;
    [_interesting_view.heightAnchor constraintEqualToConstant:[_interesting_view getTotalHeight]].active = YES;
    [_interesting_view.leadingAnchor constraintEqualToAnchor:_content_view.leadingAnchor].active = YES;
    [_interesting_view.topAnchor constraintEqualToAnchor:_content_view.topAnchor].active = YES;
    
    _options_view = [[DiscoverOptionsTableView alloc] initWithDelegate:self];
    [_content_view addSubview:_options_view];
    _options_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_options_view layoutIfNeeded];
    [_options_view.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor constant:-10].active = YES;
    [_options_view.heightAnchor constraintEqualToConstant:[_options_view getTotalHeight]].active = YES;
    [_options_view.leadingAnchor constraintEqualToAnchor:_content_view.leadingAnchor constant:5].active = YES;
    [_options_view.topAnchor constraintEqualToAnchor:_interesting_view.bottomAnchor constant:20].active = YES;
    _options_view.scrollEnabled = NO;
    _options_view.layer.cornerRadius = 8.0;
    _options_view.clipsToBounds = YES;
    
    [_content_view.bottomAnchor constraintEqualToAnchor:_options_view.bottomAnchor].active = YES;
//    _content_view.clipsToBounds = YES;
    
    [self setupDarkLayout];
    
    [_interesting_view tryLoad];
}

-(void)setupDarkLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _interesting_view.backgroundColor = [AppColorProvider foregroundColor1];
    _options_view.backgroundColor = [AppColorProvider foregroundColor1];
}

-(void)searchBarFilterButtonPressed {
    NSLog(@"Search filter button pressed");
}

-(void)search:(NSString *)query {
    NSLog(@"Search query: %@", query);
    libanixart::requests::SearchRequest search_req;
    search_req.query = TO_STDSTRING(query);
    _search_release_pages = std::make_shared<libanixart::ReleaseSearchPages>(_api_proxy.api->search().release_search(search_req));
    _search_releases.clear();
}

-(void)searchReleasesView:(SearchReleasesView*)release_view loadPage:(NSUInteger)page completionHandler:(void(^)(BOOL action_performed))completion_handler {
    __block BOOL action_performed = YES;
    [_api_proxy performAsyncBlock:^BOOL(libanixart::Api* api){
        auto new_items = self->_search_release_pages->go(page);
        self->_search_releases.insert(self->_search_releases.end(), new_items.begin(), new_items.end());
        action_performed = !self->_search_release_pages->is_end();
        return YES;
    } withUICompletion:^{
        completion_handler(action_performed);
    }];
}
-(void)searchReleasesView:(SearchReleasesView*)release_view loadNextPageWithcompletionHandler:(void(^)(BOOL action_performed))completion_handler {
    __block BOOL action_performed = YES;
    [_api_proxy performAsyncBlock:^BOOL(libanixart::Api* api){
        auto new_items = self->_search_release_pages->next();
        self->_search_releases.insert(self->_search_releases.end(), new_items.begin(), new_items.end());
        action_performed = !self->_search_release_pages->is_end();
        return YES;
    } withUICompletion:^{
        completion_handler(action_performed);
    }];
}
-(void)searchReleasesView:(SearchReleasesView*)release_view didSelectReleaseAtIndex:(NSInteger)index {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:_search_releases[index]->id] animated:YES];
}

-(libanixart::Release::Ptr)searchReleasesView:(SearchReleasesView*)release_view releaseAtIndex:(NSUInteger)index {
    return _search_releases[index];
}
-(NSUInteger)numberOfItemsForSearchReleasesView:(SearchReleasesView*)release_view {
    return _search_releases.size();
}

-(void)didSelectInterestingCell:(long long)release_id {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release_id] animated:YES];
}

-(void)popularButtonPressed {
    NSLog(@"popularButtonPressed");
}
-(void)scheduleButtonPressed {
    NSLog(@"scheduleButtonPressed");
}
-(void)collectionsButtonPressed {
    NSLog(@"collectionsButtonPressed");
}
-(void)filterButtonPressed {
    NSLog(@"filterButtonPressed");
}
-(void)randomButtonPressed {
    NSLog(@"randomButtonPressed");
}

@end
