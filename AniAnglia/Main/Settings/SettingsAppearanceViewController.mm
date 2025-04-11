//
//  SettingsAppearanceViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.04.2025.
//

#import <Foundation/Foundation.h>
#import "SettingsAppearanceViewController.h"
#import "CustomTableViewCells.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface SettingsAppearanceViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) AppSettingsDataController* settings_data_controller;
@property(nonatomic, retain) UITableView* content_table_view;
@end

@implementation SettingsAppearanceViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
    [self setup];
    [self setupLayout];
}
-(void)setup {
    _content_table_view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    [_content_table_view registerClass:TransitionTableViewCell.class forCellReuseIdentifier:[TransitionTableViewCell getIdentifier]];
    [_content_table_view registerClass:PlainTableViewCell.class forCellReuseIdentifier:[PlainTableViewCell getIdentifier]];
    [_content_table_view registerClass:MenuTableViewCell.class forCellReuseIdentifier:[MenuTableViewCell getIdentifier]];
    _content_table_view.dataSource = self;
    _content_table_view.delegate = self;
    
    [self.view addSubview:_content_table_view];
    
    _content_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_content_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_content_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_content_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _content_table_view.backgroundColor = [AppColorProvider backgroundColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
    return 1;
}
-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 2;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(NSString *)tableView:(UITableView *)table_view titleForFooterInSection:(NSInteger)section {

    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    if (section == 0) {
        if (row == 0) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier] forIndexPath:index_path];
            
            [cell setTitle:NSLocalizedString(@"app.settings.appearance.theme", "")];
            [cell setContent:[self getCurrentThemeName]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.appearance.theme.dark", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onThemeMenuItemSelected:app_settings_keys::Appearance::Theme::Dark];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.appearance.theme.light", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onThemeMenuItemSelected:app_settings_keys::Appearance::Theme::Light];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.appearance.theme.system", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onThemeMenuItemSelected:app_settings_keys::Appearance::Theme::System];
                }],
            ]];
            return cell;
        }
        if (row == 1) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier] forIndexPath:index_path];
            
            [cell setTitle:NSLocalizedString(@"app.settings.appearance.main_display_style", "")];
            [cell setContent:[self getCurrentMainDisplayStyleName]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.appearance.main_display_style.table", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onDisplayStyleMenuItemSelected:app_settings_keys::Appearance::DisplayStyle::Table];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.appearance.main_display_style.cards", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onDisplayStyleMenuItemSelected:app_settings_keys::Appearance::DisplayStyle::Cards];
                }],
            ]];
            return cell;
        }
    }
    
    return nil;
}

-(NSString*)getCurrentThemeName {
    switch ([_settings_data_controller getTheme]) {
        case app_settings_keys::Appearance::Theme::Dark:
            return NSLocalizedString(@"app.settings.appearance.theme.dark", "");
        case app_settings_keys::Appearance::Theme::Light:
            return NSLocalizedString(@"app.settings.appearance.theme.light", "");
        case app_settings_keys::Appearance::Theme::System:
            return NSLocalizedString(@"app.settings.appearance.theme.system", "");
    }
}
-(NSString*)getCurrentMainDisplayStyleName {
    switch ([_settings_data_controller getMainDisplayStyle]) {
        case app_settings_keys::Appearance::DisplayStyle::Table:
            return NSLocalizedString(@"app.settings.appearance.main_display_style.table", "");
        case app_settings_keys::Appearance::DisplayStyle::Cards:
            return NSLocalizedString(@"app.settings.appearance.main_display_style.cards", "");
    }
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    // TODO
}

-(void)onThemeMenuItemSelected:(app_settings_keys::Appearance::Theme)theme {
    [_settings_data_controller setTheme:theme];
    [_content_table_view reloadData];
}
-(void)onDisplayStyleMenuItemSelected:(app_settings_keys::Appearance::DisplayStyle)style {
    [_settings_data_controller setMainDisplayStyle:style];
    [_content_table_view reloadData];
}



@end
