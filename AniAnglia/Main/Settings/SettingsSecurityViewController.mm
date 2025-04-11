//
//  SettingsAppearanceViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.04.2025.
//

#import <Foundation/Foundation.h>
#import "SettingsSecurityViewController.h"
#import "CustomTableViewCells.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface SettingsSecurityViewController () <UITableViewDataSource, UITableViewDelegate> {
    anixart::ProfilePreferenceStatus::Ptr _profile_preferences;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppSettingsDataController* settings_data_controller;
@property(nonatomic, retain) UITableView* content_table_view;
@end

@implementation SettingsSecurityViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _settings_data_controller = [[AppDataController sharedInstance] getSettingsController];
    
    [self preSetupLayout];
    [self loadProfilePreferences];
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
-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)setupLayout {
    _content_table_view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)loadProfilePreferences {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        self->_profile_preferences = api->profiles().my_preferences();
        return YES;
    } withUICompletion:^{
        [self setup];
        [self setupLayout];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
    return 2;
}
-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 2;
        case 1:
            return 4;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(NSString *)tableView:(UITableView *)table_view titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.header", "");
    }
    return nil;
}
-(NSString *)tableView:(UITableView *)table_view titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.footer", "");
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    if (section == 0) {
        if (row == 0) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier] forIndexPath:index_path];
            
            [cell setName:NSLocalizedString(@"app.settings.privacy_and_security.change_email.name", "")];
            [cell setContent:nil];
            [cell setImage:nil tintColor:nil color:nil];
            return cell;
        }
        if (row == 1) {
            TransitionTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TransitionTableViewCell getIdentifier] forIndexPath:index_path];
            
            [cell setName:NSLocalizedString(@"app.settings.privacy_and_security.change_password.name", "")];
            [cell setContent:nil];
            [cell setImage:nil tintColor:nil color:nil];
            return cell;
        }
    }
    if (section == 1) {
        if (row == 0) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier]];
            
            [cell setTitle:NSLocalizedString(@"app.settings.privacy_and_security.stats.name", "")];
            [cell setContent:[self getStatsPrivacyName:_profile_preferences->privacy_stats]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onStatsPrivacyMenuItemSelected:anixart::Profile::StatsPermission::AllUsers];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onStatsPrivacyMenuItemSelected:anixart::Profile::StatsPermission::OnlyFriends];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onStatsPrivacyMenuItemSelected:anixart::Profile::StatsPermission::OnlyMe];
                }],
            ]];
            return cell;
        }
        if (row == 1) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier]];
            
            [cell setTitle:NSLocalizedString(@"app.settings.privacy_and_security.social.name", "")];
            [cell setContent:[self getSocialPrivacyName:_profile_preferences->privacy_social]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onSocialPrivacyMenuItemSelected:anixart::Profile::SocialPermission::AllUsers];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onSocialPrivacyMenuItemSelected:anixart::Profile::SocialPermission::OnlyFriends];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onSocialPrivacyMenuItemSelected:anixart::Profile::SocialPermission::OnlyMe];
                }],
            ]];
            return cell;
        }
        if (row == 2) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier]];
            
            [cell setTitle:NSLocalizedString(@"app.settings.privacy_and_security.activity.name", "")];
            [cell setContent:[self getActivityPrivacyName:_profile_preferences->privacy_activity]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onActivityPrivacyMenuItemSelected:anixart::Profile::ActivityPermission::AllUsers];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onActivityPrivacyMenuItemSelected:anixart::Profile::ActivityPermission::OnlyFriends];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onActivityPrivacyMenuItemSelected:anixart::Profile::ActivityPermission::OnlyMe];
                }],
            ]];
            return cell;
        }
        if (row == 3) {
            MenuTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MenuTableViewCell getIdentifier]];
            
            [cell setTitle:NSLocalizedString(@"app.settings.privacy_and_security.friend_requests.name", "")];
            [cell setContent:[self getFriendRequestsPrivacyName:_profile_preferences->privacy_friend_requests]];
            [cell setMenuActions:@[
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onFriendRequestsPrivacyMenuItemSelected:anixart::Profile::FriendRequestPermission::AllUsers];
                }],
                [UIAction actionWithTitle:NSLocalizedString(@"app.settings.privacy_and_security.privacy.nobody", "") image:nil identifier:nil handler:^(UIAction* action) {
                    [self onFriendRequestsPrivacyMenuItemSelected:anixart::Profile::FriendRequestPermission::Nobody];
                }],
            ]];
            return cell;
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    // TODO
}

-(NSString*)getStatsPrivacyName:(anixart::Profile::StatsPermission)permission {
    switch (permission) {
        case anixart::Profile::StatsPermission::AllUsers:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "");
        case anixart::Profile::StatsPermission::OnlyFriends:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "");
        case anixart::Profile::StatsPermission::OnlyMe:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "");
    }
}
-(NSString*)getSocialPrivacyName:(anixart::Profile::SocialPermission)permission {
    switch (permission) {
        case anixart::Profile::SocialPermission::AllUsers:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "");
        case anixart::Profile::SocialPermission::OnlyFriends:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "");
        case anixart::Profile::SocialPermission::OnlyMe:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "");
    }
}
-(NSString*)getActivityPrivacyName:(anixart::Profile::ActivityPermission)permission {
    switch (permission) {
        case anixart::Profile::ActivityPermission::AllUsers:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "");
        case anixart::Profile::ActivityPermission::OnlyFriends:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_friends", "");
        case anixart::Profile::ActivityPermission::OnlyMe:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "");
    }
}
-(NSString*)getFriendRequestsPrivacyName:(anixart::Profile::FriendRequestPermission)permission {
    switch (permission) {
        case anixart::Profile::FriendRequestPermission::AllUsers:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.all", "");
        case anixart::Profile::FriendRequestPermission::Nobody:
            return NSLocalizedString(@"app.settings.privacy_and_security.privacy.only_me", "");
    }
}


-(void)onStatsPrivacyMenuItemSelected:(anixart::Profile::StatsPermission)permission {
    
}
-(void)onSocialPrivacyMenuItemSelected:(anixart::Profile::SocialPermission)permission {
    
}
-(void)onActivityPrivacyMenuItemSelected:(anixart::Profile::ActivityPermission)permission {
    
}
-(void)onFriendRequestsPrivacyMenuItemSelected:(anixart::Profile::FriendRequestPermission)permission {
    
}

@end
