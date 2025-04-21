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
@property(nonatomic, retain) UIViewController* current_view_controller;


@end

@implementation ReleasesViewController

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
    _data_provider = [[ReleasesPageableDataProvider alloc] initWithPages:std::move(pages)];
    _is_container_view_controller = NO;
    
    [self updateDisplayStyle:[_settings_data_controller getMainDisplayStyle]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingsValueChanged:) name:(app_settings::notification_name) object:nil];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
    [_data_provider loadCurrentPage];
}
-(void)setup {
    [self addViewControllerView];
}
-(void)setupLayout {

}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    [_data_provider setPages:std::move(pages)];
}
-(void)reset {
    // TODO: change
    [_data_provider reset];
}

-(void)setHeaderView:(UIView*)header_view {
    // TODO
}

-(void)updateDisplayStyle:(app_settings::Appearance::DisplayStyle)display_style {
    if (_current_view_controller) {
        [_current_view_controller removeFromParentViewController];
        [_current_view_controller.view removeFromSuperview];
    }
    switch (display_style) {
        case app_settings::Appearance::DisplayStyle::Table:
            if (!_table_view_controller) {
                _table_view_controller = [[ReleasesTableViewController alloc] initWithTableView:[UITableView new] releasesPageableDataProvider:_data_provider];
                _data_provider.delegate = _table_view_controller;
                // TODO: change
                _table_view_controller.trailing_action_disabled = YES;
            }
            _data_provider.delegate = _table_view_controller;
            _current_view_controller = _table_view_controller;
            [_table_view_controller reloadData];
            break;
        case app_settings::Appearance::DisplayStyle::Cards:
            if (!_collection_view_controller) {
                _collection_view_controller = [[ReleasesCollectionViewController alloc] initWithReleasesPageableDataProvider:_data_provider axis:UICollectionViewScrollDirectionVertical];
                [_collection_view_controller setAxisItemCount:3];
            }
            _data_provider.delegate = _collection_view_controller;
            _current_view_controller = _collection_view_controller;
            [_collection_view_controller reloadData];
            break;
    }
    [self addChildViewController:_current_view_controller];
    [self addViewControllerView];
}
-(void)addViewControllerView {
    [self.view addSubview:_current_view_controller.view];
    
    _current_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    if (_is_container_view_controller) {
        [NSLayoutConstraint activateConstraints:@[
            [_current_view_controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [_current_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [_current_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [_current_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [_current_view_controller.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [_current_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [_current_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
            [_current_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        ]];
    }

}

-(void)onSettingsValueChanged:(NSNotification*)notification {
    NSString* name = notification.userInfo[app_settings::notification_info_key];
    if (![name isEqualToString:(app_settings::Appearance::main_display_style)]) {
        return;
    }
    
    NSNumber* value = notification.userInfo[app_settings::notification_info_value];
    app_settings::Appearance::DisplayStyle display_style = static_cast<app_settings::Appearance::DisplayStyle>([value integerValue]);
    [self updateDisplayStyle:display_style];
    
}

@end
