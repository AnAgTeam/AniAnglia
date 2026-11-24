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
#import "CollectionsCollectionViewController.h"
#import "ReleasesCollectionViewController.h"
#import "CommentsTableViewController.h"
#import "DynamicTableView.h"
#import "CommentRepliesViewController.h"
#import "ReleasesTableViewController.h"
#import "SegmentedPageViewController.h"
#import "NamedSectionView.h"
#import "ReleasesPopularPageViewController.h"

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

-(instancetype)init;

-(void)refresh;

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

@interface DiscoverViewController () <DiscoverInterestingViewDelegate, DiscoverOptionsViewDelegate, CommentsTableViewControllerDelegate>
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) UIStackView* content_stack_view;

@property(nonatomic, retain) DiscoverInterestingView* interesting_view;
@property(nonatomic, retain) DiscoverOptionsView* options_view;
@property(nonatomic, retain) ReleasesCollectionViewController* recomended_view_controller;
@property(nonatomic, retain) NamedSectionView* recomended_section_view;
@property(nonatomic, retain) ReleasesCollectionViewController* discussing_view_controller;
@property(nonatomic, retain) NamedSectionView* discussing_section_view;
@property(nonatomic, retain) ReleasesCollectionViewController* watching_view_controller;
@property(nonatomic, retain) NamedSectionView* watching_section_view;
@property(nonatomic, retain) CollectionsCollectionViewController* collections_view_controller;
@property(nonatomic, retain) NamedSectionView* collections_section_view;
@property(nonatomic, retain) CommentsTableViewController* comments_view_controller;
@property(nonatomic, retain) NamedSectionView* comments_section_view;

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
    self.backgroundColor = [AppColorProvider foregroundColor1];
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
    
    [self setup];
    [self setupLayout];
    [self refresh];
    
    return self;
}
-(void)setup {
    _loadable_view = [LoadableView new];
    
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collection_view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collection_view registerClass:DiscoverInterestingViewCell.class forCellWithReuseIdentifier:[DiscoverInterestingViewCell getIdentifier]];
    _collection_view.dataSource = self;
    _collection_view.delegate = self;
    _collection_view.showsHorizontalScrollIndicator = NO;

    [self addSubview:_loadable_view];
    [self addSubview:_collection_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    _collection_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_collection_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_collection_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_collection_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_collection_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_loadable_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_loadable_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_loadable_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_loadable_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)refresh {
    [_loadable_view startLoading];
    
    __block std::vector<anixart::Interesting::Ptr> new_items;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        new_items = api->search().interesting()->get();
        return YES;
    } withUICompletion:^{
        self->_interesting_arr = std::move(new_items);
        [self->_loadable_view endLoading];
        [self->_collection_view reloadData];
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
            [cell setName:NSLocalizedString(@"app.discover.popular", "")];
            [cell setImage:[UIImage systemImageNamed:@"flame"]];
            break;
        case 1:
            [cell setName:NSLocalizedString(@"app.discover.schedule", "")];
            [cell setImage:[UIImage systemImageNamed:@"calendar"]];
            break;
        case 2:
            [cell setName:NSLocalizedString(@"app.discover.collections", "")];
            [cell setImage:[UIImage systemImageNamed:@"rectangle.stack"]];
            break;
        case 3:
            [cell setName:NSLocalizedString(@"app.discover.random", "")];
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

#ifndef L
#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")
#endif

#pragma mark - Расписание

@interface ScheduleViewController : UITableViewController
@end

@implementation ScheduleViewController {
    NSArray<NSString*>* _day_titles;
    NSArray<NSArray<NSDictionary*>*>* _day_items;
    UIActivityIndicatorView* _spinner;
    UILabel* _message_label;
}

-(instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    self.title = L(@"app.discover.schedule", @"Расписание");
    _day_titles = @[];
    _day_items = @[];
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.backgroundColor = [AppColorProvider backgroundColor];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _spinner.color = [AppColorProvider textSecondaryColor];
    _message_label = [UILabel new];
    _message_label.numberOfLines = 0;
    _message_label.textAlignment = NSTextAlignmentCenter;
    _message_label.textColor = [AppColorProvider textSecondaryColor];
    _message_label.font = [UIFont systemFontOfSize:15];
    UIView* background = [UIView new];
    [background addSubview:_spinner];
    [background addSubview:_message_label];
    self.tableView.backgroundView = background;
    
    [_spinner startAnimating];
    [self load];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.tableView.backgroundView.bounds;
    _spinner.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - 40);
    _message_label.frame = CGRectMake(24, CGRectGetMidY(bounds) - 80, bounds.size.width - 48, 160);
}

-(void)load {
    NSArray<NSString*>* day_keys = @[@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday"];
    NSArray<NSString*>* day_names = @[
        L(@"app.schedule.monday", @"Понедельник"), L(@"app.schedule.tuesday", @"Вторник"), L(@"app.schedule.wednesday", @"Среда"),
        L(@"app.schedule.thursday", @"Четверг"), L(@"app.schedule.friday", @"Пятница"), L(@"app.schedule.saturday", @"Суббота"),
        L(@"app.schedule.sunday", @"Воскресенье")
    ];
    NSInteger weekday = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:[NSDate date]]; // 1 = воскресенье
    NSInteger today_index = (weekday + 5) % 7;
    
    __block NSMutableArray<NSString*>* titles = [NSMutableArray new];
    __block NSMutableArray<NSArray<NSDictionary*>*>* items = [NSMutableArray new];
    __block NSString* keys_text = @"";
    
    [[LibanixartApi sharedInstance] asyncCall:^BOOL(anixart::Api* api) {
        network::JsonObject response = api->get_session().api_request(anixart::requests::schedule::schedule());
        
        auto get_string = [](const boost::json::object& object, const char* key) -> std::string {
            auto it = object.find(key);
            if (it != object.end() && it->value().is_string()) {
                const auto& js = it->value().as_string();
                return std::string(js.data(), js.size());
            }
            return std::string();
        };
        auto get_int = [](const boost::json::object& object, const char* key) -> long long {
            auto it = object.find(key);
            if (it == object.end()) {
                return 0;
            }
            const boost::json::value& value = it->value();
            if (value.is_int64()) return (long long)value.as_int64();
            if (value.is_uint64()) return (long long)value.as_uint64();
            if (value.is_double()) return (long long)value.as_double();
            return 0;
        };
        
        for (NSUInteger day = 0; day < day_keys.count; day++) {
            auto it = response.find(day_keys[day].UTF8String);
            if (it == response.end() || !it->value().is_array()) {
                continue;
            }
            NSMutableArray<NSDictionary*>* day_items = [NSMutableArray new];
            for (const auto& entry : it->value().as_array()) {
                if (!entry.is_object()) {
                    continue;
                }
                const boost::json::object& object = entry.as_object();
                long long release_id = get_int(object, "id");
                if (release_id == 0) {
                    continue;
                }
                std::string title = get_string(object, "title_ru");
                if (title.empty()) {
                    title = get_string(object, "title_original");
                }
                long long released = get_int(object, "episodes_released");
                long long total = get_int(object, "episodes_total");
                NSString* subtitle = @"";
                if (released > 0 && total > 0) {
                    subtitle = [NSString stringWithFormat:@"%@ %lld %@ %lld", L(@"app.schedule.episodes", @"Серий:"), released, L(@"app.schedule.of", @"из"), total];
                } else if (released > 0) {
                    subtitle = [NSString stringWithFormat:@"%@ %lld", L(@"app.schedule.episodes", @"Серий:"), released];
                }
                [day_items addObject:@{@"id": @(release_id), @"title": TO_NSSTRING(title), @"subtitle": subtitle}];
            }
            if (day_items.count > 0) {
                NSString* name = day_names[day];
                if ((NSInteger)day == today_index) {
                    name = [name stringByAppendingFormat:@" • %@", L(@"app.schedule.today", @"сегодня")];
                }
                [titles addObject:name];
                [items addObject:day_items];
            }
        }
        if (titles.count == 0) {
            NSMutableArray<NSString*>* keys = [NSMutableArray new];
            for (const auto& kv : response) {
                std::string key(kv.key().data(), kv.key().size());
                [keys addObject:TO_NSSTRING(key)];
            }
            keys_text = [keys componentsJoinedByString:@", "];
        }
        return NO; // asyncCall: YES означает ошибку
    } completion:^(BOOL errored) {
        [self->_spinner stopAnimating];
        self->_day_titles = titles;
        self->_day_items = items;
        if (errored) {
            self->_message_label.text = L(@"app.schedule.error", @"Не удалось загрузить расписание. Проверьте соединение и попробуйте ещё раз.");
        } else if (titles.count == 0) {
            self->_message_label.text = [NSString stringWithFormat:@"%@\n%@", L(@"app.schedule.empty", @"Расписание пусто или имеет неизвестный формат."), keys_text];
        } else {
            self->_message_label.text = nil;
        }
        [self.tableView reloadData];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return _day_titles.count;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return _day_items[section].count;
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return _day_titles[section];
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary* item = _day_items[indexPath.section][indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.backgroundColor = [AppColorProvider foregroundColor1];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.textColor = [AppColorProvider textColor];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = [AppColorProvider textSecondaryColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* item = _day_items[indexPath.section][indexPath.row];
    anixart::ReleaseID release_id = static_cast<anixart::ReleaseID>((int64_t)[item[@"id"] longLongValue]);
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release_id] animated:YES];
}

@end

@implementation DiscoverViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    [self setupLayout];
    [self refresh];
}

-(void)setup {
    _scroll_view = [UIScrollView new];
    
    _content_stack_view = [UIStackView new];
    _content_stack_view.axis = UILayoutConstraintAxisVertical;
    _content_stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _content_stack_view.alignment = UIStackViewAlignmentCenter;
    _content_stack_view.spacing = 7;
    
    _interesting_view = [DiscoverInterestingView new];
    _interesting_view.delegate = self;
    
    _options_view = [DiscoverOptionsView new];
    _options_view.delegate = self;
    
    _recomended_view_controller = [[ReleasesCollectionViewController alloc] initWithAxis:UICollectionViewScrollDirectionHorizontal];
    _recomended_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_recomended_view_controller];
    
    _recomended_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.discover.recomended", "") view:_recomended_view_controller.view];
    _recomended_section_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _discussing_view_controller = [[ReleasesCollectionViewController alloc] initWithAxis:UICollectionViewScrollDirectionHorizontal];
    _discussing_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_discussing_view_controller];
    
    _discussing_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.discover.discussing", "") view:_discussing_view_controller.view];
    _discussing_section_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _watching_view_controller = [[ReleasesCollectionViewController alloc] initWithAxis:UICollectionViewScrollDirectionHorizontal];
    _watching_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_watching_view_controller];
    
    _watching_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.discover.watching", "") view:_watching_view_controller.view];
    _watching_section_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _collections_view_controller = [[CollectionsCollectionViewController alloc] initWithAxis:UICollectionViewScrollDirectionHorizontal];
    _collections_view_controller.is_container_view_controller = YES;
    [self addChildViewController:_collections_view_controller];
    
    _collections_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.discover.week_collections", "") view:_collections_view_controller.view];
    _collections_section_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _comments_view_controller = [[CommentsTableViewController alloc] initWithTableView:[DynamicTableView new] pages:_api_proxy.api->search().comments_week()];
    _comments_view_controller.enable_origin_reference = YES;
    _comments_view_controller.is_container_view_controller = YES;
    _comments_view_controller.delegate = self;
    [self addChildViewController:_comments_view_controller];
    
    _comments_section_view = [[NamedSectionView alloc] initWithName:NSLocalizedString(@"app.discover.week_comments", "") view:_comments_view_controller.view];
    _comments_section_view.layoutMargins = UIEdgeInsetsMake(10, 0, 0, 0);

    [self.view addSubview:_scroll_view];
    [_scroll_view addSubview:_content_stack_view];
    [_content_stack_view addArrangedSubview:_interesting_view];
    [_content_stack_view addArrangedSubview:_options_view];
    [_content_stack_view addArrangedSubview:_recomended_section_view];
    [_content_stack_view addArrangedSubview:_discussing_section_view];
    [_content_stack_view addArrangedSubview:_watching_section_view];
    [_content_stack_view addArrangedSubview:_collections_section_view];
    [_content_stack_view addArrangedSubview:_comments_section_view];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _interesting_view.translatesAutoresizingMaskIntoConstraints = NO;
    _options_view.translatesAutoresizingMaskIntoConstraints = NO;
    _recomended_section_view.translatesAutoresizingMaskIntoConstraints = NO;
    _discussing_section_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watching_section_view.translatesAutoresizingMaskIntoConstraints = NO;
    _collections_section_view.translatesAutoresizingMaskIntoConstraints = NO;
    _comments_section_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [_content_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor],
        [_content_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_content_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_content_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_content_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor],
        
        [_interesting_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_interesting_view.heightAnchor constraintEqualToConstant:200],
        [_options_view.widthAnchor constraintEqualToAnchor:_content_stack_view.layoutMarginsGuide.widthAnchor],
        [_recomended_section_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_recomended_section_view.heightAnchor constraintEqualToConstant:290],
        [_discussing_section_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_discussing_section_view.heightAnchor constraintEqualToConstant:290],
        [_watching_section_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_watching_section_view.heightAnchor constraintEqualToConstant:290],
        [_collections_section_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_collections_section_view.heightAnchor constraintEqualToConstant:250],
        [_comments_section_view.widthAnchor constraintEqualToAnchor:_content_stack_view.widthAnchor],
        [_comments_section_view.heightAnchor constraintGreaterThanOrEqualToConstant:200],
    ]];
}

-(void)refresh {
    [_interesting_view refresh];
    
    ReleasesPageableDataProvider* recomended_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:_api_proxy.api->search().recomendations(0)];
    [_recomended_view_controller setReleasesPageableDataProvider:recomended_data_provider];
    
    ReleasesPageableDataProvider* discussing_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:_api_proxy.api->search().discussing()];
    [_discussing_view_controller setReleasesPageableDataProvider:discussing_data_provider];
    
    ReleasesPageableDataProvider* watching_data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:_api_proxy.api->search().currently_watching(0)];
    [_watching_view_controller setReleasesPageableDataProvider:watching_data_provider];
    
    CollectionsPageableDataProvider* week_collections_data_provider = [[CollectionsPageableDataProvider alloc] initWithPages:_api_proxy.api->collections().all_collections(anixart::Collection::Sort::WeekPopular, 2, 0)];
    [_collections_view_controller setDataProvider:week_collections_data_provider];
    
    CommentsPageableDataProvider* comments_data_provider = [[CommentsPageableDataProvider alloc] initWithPages:_api_proxy.api->search().comments_week()];
    [_comments_view_controller setDataProvider:comments_data_provider];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(IBAction)onFilterBarButtonPressed:(UIBarButtonItem*)sender {
    [self.navigationController pushViewController:[FilterViewController new] animated:YES];
}

-(void)didPopularPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController pushViewController:[ReleasesPopularPageViewController new] animated:YES];
}
-(void)didSchedulePressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:[ScheduleViewController new] animated:YES];
}
-(void)didCollectionsPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController pushViewController:[[CollectionsCollectionViewController alloc] initWithPages:_api_proxy.api->collections().all_collections(anixart::Collection::Sort::YearPopular, 1, 0) axis:UICollectionViewScrollDirectionVertical] animated:YES];
}
-(void)didRandomPressedForDiscoverOptionsView:(DiscoverOptionsView *)discover_options_view {
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithRandomRelease] animated:YES];
}

-(void)discoverInterestingView:(DiscoverInterestingView*)interesting_view didSelectInteresting:(anixart::Interesting::Ptr)interesting {
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
