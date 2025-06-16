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
#import "ReleasesPageableDataProvider.h"

@interface ReleasesViewController ()
@property(nonatomic, strong) AppSettingsDataController* settings_data_controller;
@property(nonatomic, retain) ReleasesPageableDataProvider* data_provider;
@property(nonatomic, retain) ReleasesTableViewController* table_view_controller;
@property(nonatomic, retain) ReleasesCollectionViewController* collection_view_controller;
@property(nonatomic, retain) UIViewController<PageableDataProviderDelegate>* current_view_controller;

@end

@implementation ReleasesViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
    _data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _is_container_view_controller = NO;
    
    return self;
}

-(instancetype)initWithReleasesPageableDataProvider:(ReleasesPageableDataProvider*)releases_pageable_data_provider {
    self = [super init];
    
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
    _data_provider = releases_pageable_data_provider;
    _is_container_view_controller = NO;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    UIViewController<PageableDataProviderDelegate>* view_controller = [self getViewControllerForDisplayStyle:[_settings_data_controller getMainDisplayStyle]];
    [self setContentViewController:view_controller];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingsValueChanged:) name:(app_settings::notification_name) object:nil];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}

-(void)reload {
    [_data_provider reload];
}

-(void)refresh {
    [_data_provider refresh];
}

-(void)setHeaderView:(UIView*)header_view {
    // TODO
}

-(UIViewController<PageableDataProviderDelegate>*)getViewControllerForDisplayStyle:(app_settings::Appearance::DisplayStyle)display_style {
    switch (display_style) {
        case app_settings::Appearance::DisplayStyle::Table:
            return [self getTableViewControllerWithDataProvider:_data_provider];
        case app_settings::Appearance::DisplayStyle::Cards:
            return [self getCollectionViewControllerWithDataProvider:_data_provider];
    }
}
-(void)setContentViewController:(UIViewController<PageableDataProviderDelegate>*)view_controller {
    if (_current_view_controller) {
        [_current_view_controller removeFromParentViewController];
        [_current_view_controller.view removeFromSuperview];
    }
    _current_view_controller = view_controller;
    
    [self addChildViewController:_current_view_controller];
    [self.view addSubview:_current_view_controller.view];
    
    _current_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_current_view_controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_current_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_current_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_current_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    [_current_view_controller didMoveToParentViewController:self];
}

-(UIViewController<PageableDataProviderDelegate>*)getTableViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider {
    return [[ReleasesTableViewController alloc] initWithTableView:[UITableView new] releasesPageableDataProvider:_data_provider];
}
-(UIViewController<PageableDataProviderDelegate>*)getCollectionViewControllerWithDataProvider:(ReleasesPageableDataProvider*)data_provider {
    ReleasesCollectionViewController* view_controller = [[ReleasesCollectionViewController alloc] initWithReleasesPageableDataProvider:_data_provider axis:UICollectionViewScrollDirectionVertical];
    [view_controller setAxisItemCount:3];
    return view_controller;
}

-(void)onSettingsValueChanged:(NSNotification*)notification {
    NSString* name = notification.userInfo[app_settings::notification_info_key];
    if (![name isEqualToString:(app_settings::Appearance::main_display_style)]) {
        return;
    }
    
    NSNumber* value = notification.userInfo[app_settings::notification_info_value];
    app_settings::Appearance::DisplayStyle display_style = static_cast<app_settings::Appearance::DisplayStyle>([value integerValue]);
    
    UIViewController<PageableDataProviderDelegate>* view_controller = [self getViewControllerForDisplayStyle:display_style];
    [self setContentViewController:view_controller];
}

@end
