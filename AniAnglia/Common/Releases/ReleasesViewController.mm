//
//  ReleasesViewController..m
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesViewController.h"
#import "ReleasesTableViewController.h"
#import "ReleasesCollectionViewController.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface ReleasesViewController () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    app_settings::Appearance::DisplayStyle _display_style;
}
@property(nonatomic, strong) AppSettingsDataController* settings_data_controller;
@property(nonatomic, retain) ReleasesTableViewController* table_view_controller;
@property(nonatomic, retain) ReleasesCollectionViewController* collection_view_controller;
@property(nonatomic, retain) UIViewController* current_view_controller;


@end

@implementation ReleasesViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
//    _display_style = [_settings_data_controller getMainDisplayStyle];
    // TODO: get from settings
    _display_style = app_settings::Appearance::DisplayStyle::Cards;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    
}
-(void)setupLayout {
    switch (_display_style) {
        case app_settings::Appearance::DisplayStyle::Table:
            _table_view_controller = [[ReleasesTableViewController alloc] initWithPages:std::move(_pages)];
            _current_view_controller = _table_view_controller;
            break;
        case app_settings::Appearance::DisplayStyle::Cards:
            _collection_view_controller = [[ReleasesCollectionViewController alloc] initWithPages:std::move(_pages) axis:UICollectionViewScrollDirectionVertical];
            [_collection_view_controller setAxisItemCount:3];
            _current_view_controller = _collection_view_controller;
            break;
    }
    [self addChildViewController:_current_view_controller];
    
    [self.view addSubview:_current_view_controller.view];
    
    _current_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_current_view_controller.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_current_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_current_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_current_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

// TODO: unify
-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    switch (_display_style) {
        case app_settings::Appearance::DisplayStyle::Table:
            [_table_view_controller setPages:std::move(pages)];
            break;
        case app_settings::Appearance::DisplayStyle::Cards:
            [_collection_view_controller setPages:std::move(pages)];
            break;
    }
}
-(void)reset {
    switch (_display_style) {
        case app_settings::Appearance::DisplayStyle::Table:
            [_table_view_controller reset];
            break;
        case app_settings::Appearance::DisplayStyle::Cards:
            [_collection_view_controller reset];
            break;
    }
}

-(void)setHeaderView:(UIView*)header_view {
    // TODO
}

@end
