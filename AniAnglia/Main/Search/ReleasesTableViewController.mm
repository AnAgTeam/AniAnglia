//
//  SearchViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesTableViewController.h"
#import "ReleasesTableView.h"
#import "FilterViewController.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "LibanixartApi.h"
#import "StringCvt.h"

@interface ReleasesTableViewController () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
}
@property(nonatomic, retain) ReleasesTableView* releases_table_view;

@end

@implementation ReleasesTableViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    _releases_table_view = [[ReleasesTableView alloc] initWithPages:std::move(_pages)];
    
    [self.view addSubview:_releases_table_view];
    
    _releases_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_releases_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_releases_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_releases_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_releases_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}
-(void)setupLayout {

}

-(void)updatePages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    [_releases_table_view setPages:std::move(pages)];
}

@end
