//
//  ProfileEditViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 06.04.2025.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "SettingsProfileViewController.h"
#import "CustomTableViewCells.h"
#import "AppDataController.h"
#import "SettingsAppearanceViewController.h"
#import "SettingsSecurityViewController.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppSettingsDataController* app_settings_controller;
@property(nonatomic, retain) UITableView* content_table_view;

@end

@implementation SettingsViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_settings_controller = [[AppDataController sharedInstance] getSettingsController];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    self.navigationItem.title = NSLocalizedString(@"app.settings.title", "");
    
    _content_table_view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    [_content_table_view registerClass:TransitionTableViewCell.class forCellReuseIdentifier:[TransitionTableViewCell getIdentifier]];
    [_content_table_view registerClass:SwitchTableViewCell.class forCellReuseIdentifier:[SwitchTableViewCell getIdentifier]];
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
    return 4;
}
-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 4;
        case 2:
            return 1;
        case 3:
            return 2;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return 50;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 2:
            return NSLocalizedString(@"app.settings.alternative_connection.footer", "");
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    if (section == 0) {
        if (row == 0) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.profile.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"person.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemRedColor]];
            return cell;
        }
        if (row == 1) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.privacy_and_security.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"lock.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemGrayColor]];
            return cell;
        }
    }
    if (section == 1) {
        if (row == 0) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.appearance.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"eye.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemIndigoColor]];
            return cell;
        }
        if (row == 1) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.notifications.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"bell.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemPurpleColor]];
            return cell;
        }
        if (row == 2) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.data_control.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"externaldrive.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemGreenColor]];
            return cell;
        }
        if (row == 3) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.playback.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"arrowtriangle.right.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemBlueColor]];
            return cell;
        }
    }
    if (section == 2) {
        if (row == 0) {
            SwitchTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[SwitchTableViewCell getIdentifier]];
            
            [cell setContent:NSLocalizedString(@"app.settings.alternative_connection.name", "")];
            [cell setOn:[_app_settings_controller getAlternativeConnection]];
            [cell setHandler:^(BOOL is_on) {
                [self onAlternativeConnectionSwitched:is_on];
            }];
            return cell;
        }
    }
    if (section == 3) {
        if (row == 0) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.help.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"questionmark"] tintColor:[UIColor whiteColor] color:[UIColor systemGrayColor]];
            return cell;
        }
        if (row == 1) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier]];
            
            [cell setName:NSLocalizedString(@"app.settings.rules.name", "")];
            [cell setContent:nil];
            [cell setImage:[UIImage systemImageNamed:@"shield.fill"] tintColor:[UIColor whiteColor] color:[UIColor systemPinkColor]];
            return cell;
        }
    }
    
    // should never reach here
    return nil;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    if (section == 0) {
        if (row == 0) {
            [self onProfileSelected];
        }
        if (row == 1) {
            [self onPrivacyAndSectitySelected];
        }
    }
    if (section == 1) {
        if (row == 0) {
            [self onAppearanceSelected];
        }
    }
}

-(void)onLogoutItemSelected {
    
}
-(void)onChangeCustomStatusItemSelected {
    
}
-(void)onProfileSelected {
    [self.navigationController pushViewController:[SettingsProfileViewController new] animated:YES];
}
-(void)onPrivacyAndSectitySelected {
    [self.navigationController pushViewController:[SettingsSecurityViewController new] animated:YES];
}
-(void)onAppearanceSelected {
    [self.navigationController pushViewController:[SettingsAppearanceViewController new] animated:YES];
}

-(void)onAlternativeConnectionSwitched:(BOOL)is_on {
    [_app_settings_controller setAlternativeConnection:is_on];
}

@end
