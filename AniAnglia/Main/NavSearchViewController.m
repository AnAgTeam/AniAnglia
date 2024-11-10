//
//  NavigationAndSearchController.m
//  AniAnglia
//
//  Created by Toilettrauma on 03.11.2024.
//

#import <Foundation/Foundation.h>
#import "NavSearchViewController.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface HistoryTableViewCell : UITableViewCell
@property(nonatomic, retain) UIImageView* magnifier_image_view;
@property(nonatomic, retain) UILabel* history_item_label;

+(NSString*)getIndentifier;
@end

@interface NavigationSearchViewController () {
    struct {
        BOOL search_method;
        BOOL filter_method;
    } _delegate_responds_to;
}
@property(nonatomic) AppDataController* app_data;
@property(nonatomic, retain) UIBarButtonItem* search_cancel_bar_item;
@property(nonatomic, retain) UIBarButtonItem* search_filter_bar_item;
@property(nonatomic, retain) UITableView* search_table_view;
@property(nonatomic, retain) NSLayoutConstraint* search_table_view_tpc;
@property(nonatomic, retain) NSLayoutConstraint* search_table_view_ldc;
@property(nonatomic, retain) NSLayoutConstraint* search_table_view_trc;
@property(nonatomic, retain) NSLayoutConstraint* search_table_view_btc;
@end

@implementation HistoryTableViewCell

+(NSString*)getIndentifier {
    return @"HistoryTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setupView];
    
    return self;
}

-(void)setupView {
    _magnifier_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]];
    [self addSubview:_magnifier_image_view];
    _magnifier_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_magnifier_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5.0].active = YES;
    [_magnifier_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_magnifier_image_view.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.55].active = YES;
    [_magnifier_image_view.widthAnchor constraintEqualToAnchor:_magnifier_image_view.heightAnchor].active = YES;

    _history_item_label = [UILabel new];
    [self addSubview:_history_item_label];
    _history_item_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_history_item_label.leadingAnchor constraintEqualToAnchor:_magnifier_image_view.trailingAnchor constant:5].active = YES;
    [_history_item_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_history_item_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
    [_history_item_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    _history_item_label.textAlignment = NSTextAlignmentLeft;
    
    [self setupLayout];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _magnifier_image_view.tintColor = [AppColorProvider textColor];
    _history_item_label.textColor = [AppColorProvider textColor];
}

@end

@implementation NavigationSearchViewController

-(void)setDefaults {
    _app_data = [AppDataController sharedInstance];
    _filter_enabled = NO;
    _history_enabled = NO;
    _search_delegate = nil;
    _delegate_responds_to.search_method = NO;
    _delegate_responds_to.filter_method = NO;
}

-(instancetype)init {
    self = [super init];
    
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

-(instancetype)initWithNibName:(NSString *)nib_name_or_nil bundle:(NSBundle *)nib_bundle_or_nil {
    self = [super initWithNibName:nib_name_or_nil bundle:nib_bundle_or_nil];
    
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

/* called from storyboard */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    [self setDefaults];
    [self setupSearchViews];
    
    return self;
}

-(instancetype)initWithDelegate:(id<NavigationSearchDelegate>)view_controller filterEnabled:(BOOL)filter_enabled {
    self = [super init];
    
    [self setDefaults];
    _filter_enabled = filter_enabled;
    [self setSearchDelegate:view_controller];
    [self setupSearchViews];
    
    return self;
}

-(void)setSearchDelegate:(id<NavigationSearchDelegate>)search_delegate {
    _search_delegate = search_delegate;
    NSObject<NavigationSearchDelegate>* delegate = (NSObject<NavigationSearchDelegate>*)search_delegate;
    _delegate_responds_to.search_method = [delegate respondsToSelector:@selector(search:)];
    _delegate_responds_to.filter_method = [delegate respondsToSelector:@selector(searchBarFilterButtonPressed)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHistoryView];
}

-(void)setupSearchViews {
    _search_bar = [UISearchBar new];
    _search_bar.delegate = self;
    self.navigationItem.titleView = _search_bar;
    self.navigationController.hidesBarsOnSwipe = YES;
    _search_cancel_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonPressed:)];
    _search_filter_bar_item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarFilterButtonPressed:)];
}

-(void)setupHistoryView {
    _search_table_view = [UITableView new];
//    [self.view addSubview:_search_table_view];
    _search_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _search_table_view_tpc = [_search_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
    _search_table_view_btc = [_search_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    _search_table_view_ldc = [_search_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor];
    _search_table_view_trc = [_search_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor];
    _search_table_view.hidden = YES;
    [_search_table_view registerClass:HistoryTableViewCell.class forCellReuseIdentifier:[HistoryTableViewCell getIndentifier]];
    [_search_table_view setDelegate:self];
    [_search_table_view setDataSource:self];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return [_app_data getSearchHistoryLength];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    HistoryTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[HistoryTableViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    cell.history_item_label.text = [_app_data getSearchHistoryItemAtIndex:index];

    return cell;
}

-(void)cancelSearchBar {
    [_search_bar endEditing:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationItem.leftBarButtonItem = _search_cancel_bar_item;
    if (_filter_enabled) {
        self.navigationItem.rightBarButtonItem = _search_filter_bar_item;
    }
    
    if (_history_enabled) {
        [self.view addSubview:_search_table_view];
        [NSLayoutConstraint activateConstraints:@[
            _search_table_view_tpc,
            _search_table_view_btc,
            _search_table_view_ldc,
            _search_table_view_trc
        ]];
        _search_table_view.hidden = NO;
        [_search_table_view reloadData];
    }
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    self.navigationController.hidesBarsOnSwipe = YES;
    [self cancelSearchBar];
    
    if (_history_enabled) {
        [NSLayoutConstraint deactivateConstraints:@[
            _search_table_view_tpc,
            _search_table_view_btc,
            _search_table_view_ldc,
            _search_table_view_trc
        ]];
        [_search_table_view removeFromSuperview];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)search_bar {
    if (search_bar != _search_bar) {
        return;
    }
    if ([search_bar.text length] > 0) {
        if (_history_enabled) {
            [_search_table_view reloadData];
            [_app_data addSearchHistoryItem:search_bar.text];
        }
        if (_delegate_responds_to.search_method) {
            [_search_delegate search:search_bar.text];
        }
        [search_bar endEditing:YES];
    }
}

-(IBAction)searchBarCancelButtonPressed:(id)sender {
    _search_bar.text = @"";
    [_search_bar endEditing:YES];
}
-(IBAction)searchBarFilterButtonPressed:(id)sender {
    if (_delegate_responds_to.filter_method) {
        [_search_delegate searchBarFilterButtonPressed];
    }
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    HistoryTableViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    
    _search_bar.text = cell.history_item_label.text;
    [_search_bar endEditing:YES];
    if (_delegate_responds_to.search_method) {
        [_search_delegate search:_search_bar.text];
    }
}
@end
