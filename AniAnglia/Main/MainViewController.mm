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
#import "ReleasesTableView.h"
#import "SearchReleasesTableView.h"
#import "ReleasesSearchHistoryView.h"

@interface MainPageViewController : UIViewController {
    libanixart::FilterPages::UniqPtr _filter_request;
}
@property(nonatomic, retain) ReleasesTableView* releases_table_view;

-(instancetype)initWithPages:(libanixart::FilterPages::UniqPtr)pages;

@end

@interface MainPagesViewController : UIPageViewController
@property(nonatomic, retain) UISegmentedControl* pages_segment_control;
@property(nonatomic, retain) NSArray<MainPageViewController*>* page_view_contorollers;

@end

@interface MainViewController ()
@property(nonatomic) LibanixartApi* api_proxy;

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

    [self setupLayout];
}
-(void)setupLayout {
    
}

@end

@implementation MainPagesViewController

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
    self.search_view = [SearchReleasesTableView new];
    
    [self setupView];
}

-(void)setupView {
    
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}


@end
