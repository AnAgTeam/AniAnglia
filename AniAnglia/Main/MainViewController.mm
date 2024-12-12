//
//  MainViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "ReleaseViewController.h"
#import "StringCvt.h"
#import "ReleasesQuerySearch.h"
#import "ReleasesTableView.h"

@interface MainPageViewController : UIViewController {
    libanixart::FilterPages::UniqPtr _filter_request;
}
@property(nonatomic, retain) ReleasesTableView* releases_table_view;
@property(nonatomic, weak, setter=setDataSource:) id<ReleasesTableViewDataSource> data_source;
@property(nonatomic, weak) id<ReleasesTableViewDelegate> delegate;

-(instancetype)initWithPages:(libanixart::FilterPages::UniqPtr)pages;

@end

@interface MainPagesViewController : UIPageViewController <ReleasesTableViewDelegate, ReleasesTableViewDataSource>
@property(nonatomic, retain) UISegmentedControl* pages_segment_control;
@property(nonatomic, retain) NSArray<MainPageViewController*>* page_view_contorollers;

@end

@interface MainViewController ()
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) ReleasesQuerySearchDefaultDataSource* search_query_data_source;

@end

@implementation MainPageViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}
-(void)setupView {
    _releases_table_view = [ReleasesTableView new];
    [self.view addSubview:_releases_table_view];
    _releases_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_releases_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_releases_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_releases_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_releases_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    _releases_table_view.delegate = _delegate;
    _releases_table_view.data_source = _data_source;

    [self setupLayout];
}
-(void)setupLayout {
    
}

-(void)setDataSource:(id<ReleasesTableViewDataSource>)data_source {
    _data_source = data_source;
    if ([self isViewLoaded]) {
        _releases_table_view.data_source = _data_source;
    }
}
-(void)setDelegate:(id<ReleasesTableViewDelegate>)delegate {
    _delegate = delegate;
    if ([self isViewLoaded]) {
        _releases_table_view.delegate = _delegate;
    }
}

@end

@implementation MainPagesViewController

-(MainPageViewController*)createPageViewController {
    MainPageViewController* page_view_controller = [MainPageViewController new];
    page_view_controller.delegate = self;
    page_view_controller.data_source = self;
    return page_view_controller;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}


@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    self.inline_search_view = [ReleasesSearchHistoryView new];
    SearchReleasesTableView* search_releases_view = [SearchReleasesTableView new];
    search_releases_view.delegate = self;
    _search_query_data_source = [ReleasesQuerySearchDefaultDataSource new];
    search_releases_view.data_source = _search_query_data_source;
    self.search_view = search_releases_view;
    
    [self setupView];
}

-(void)setupView {
    
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)releasesTableView:(ReleasesTableView*)releases_view didSelectReleaseAtIndex:(NSInteger)index {
    libanixart::Release::Ptr release = [_search_query_data_source releasesTableView:releases_view releaseAtIndex:index];
    [self.navigationController pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}


@end
