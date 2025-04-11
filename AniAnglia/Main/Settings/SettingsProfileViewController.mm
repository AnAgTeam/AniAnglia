//
//  ProfileEditProfileViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 08.04.2025.
//

#import <Foundation/Foundation.h>
#import "SettingsProfileViewController.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "LoadableView.h"
#import "CustomTableViewCells.h"
#import "SharedRunningData.h"
#import "MainWindow.h"
#import "AuthViewController.h"
#import "AppDataController.h"

@interface SettingsProfileViewController () <UITableViewDataSource, UITableViewDelegate, TextFieldTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    anixart::Profile::Ptr _profile;
    
    NSString* _to_change_username;
    NSString* _to_change_custom_status;
    NSString* _to_change_social_vk;
    NSString* _to_change_social_tg;
    NSString* _to_change_social_discord;
    NSString* _to_change_social_instagram;
    NSString* _to_change_social_tiktok;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, strong) AppDataController* app_data_controller;
@property(nonatomic, strong) SharedRunningData* shared_running_data;
@property(nonatomic, strong) UIImagePickerController* image_picker_controller;
@property(nonatomic, retain) UITableView* content_table_view;
@property(nonatomic, retain) UIButton* avatar_button;
@property(nonatomic, retain) LoadableImageView* avatar_image_view;
@property(nonatomic, retain) UIBarButtonItem* save_bar_button;

@end

@implementation SettingsProfileViewController

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _app_data_controller = [AppDataController sharedInstance];
    _shared_running_data = [SharedRunningData sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetupLayout];
    [_shared_running_data asyncGetMyProfile:^(anixart::Profile::Ptr profile) {
        self->_profile = profile;
        [self setup];
        [self setupLayout];
    }];
}
-(void)setup {
    _save_bar_button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"app.settings.profile.save_button.title", "") style:UIBarButtonItemStyleDone target:self action:@selector(onSaveBarButtonPressed:)];
    self.navigationItem.rightBarButtonItem = _save_bar_button;
    _save_bar_button.enabled = NO;
    
    _content_table_view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    [_content_table_view registerClass:TextFieldTableViewCell.class forCellReuseIdentifier:[TextFieldTableViewCell getIdentifier]];
    [_content_table_view registerClass:TransitionTableViewCell.class forCellReuseIdentifier:[TransitionTableViewCell getIdentifier]];
    [_content_table_view registerClass:PlainTableViewCell.class forCellReuseIdentifier:[PlainTableViewCell getIdentifier]];
    _content_table_view.dataSource = self;
    _content_table_view.delegate = self;
    
    _avatar_button = [UIButton new];
    _avatar_button.layoutMargins = UIEdgeInsetsMake(0, 0, 10, 0);
    [_avatar_button addTarget:self action:@selector(onAvatarPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _avatar_image_view = [LoadableImageView new];
    _avatar_image_view.layer.cornerRadius = 60;
    
    _content_table_view.tableHeaderView = _avatar_button;
    
    [self.view addSubview:_content_table_view];
    [_avatar_button addSubview:_avatar_image_view];
    
    _content_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_content_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_content_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_content_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_content_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [_avatar_button.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_avatar_button.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_avatar_button.centerXAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        
        [_avatar_image_view.topAnchor constraintEqualToAnchor:_avatar_button.layoutMarginsGuide.topAnchor],
        [_avatar_image_view.leadingAnchor constraintEqualToAnchor:_avatar_button.layoutMarginsGuide.leadingAnchor],
        [_avatar_image_view.trailingAnchor constraintEqualToAnchor:_avatar_button.layoutMarginsGuide.trailingAnchor],
        [_avatar_image_view.bottomAnchor constraintEqualToAnchor:_avatar_button.layoutMarginsGuide.bottomAnchor],
        [_avatar_image_view.heightAnchor constraintEqualToConstant:120],
        [_avatar_image_view.widthAnchor constraintEqualToConstant:120]
    ]];
    
    [self reloadAvatar];
    
    [_avatar_button setNeedsLayout];
    [_avatar_button layoutIfNeeded];
}
-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}
-(void)setupLayout {
    _content_table_view.backgroundColor = [AppColorProvider backgroundColor];
    _avatar_image_view.backgroundColor = [AppColorProvider foregroundColor1];
}
-(void)reloadAvatar {
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(_profile->avatar_url)];
    [_avatar_image_view tryLoadImageWithURL:image_url];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
    return 4;
}
-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 5;
        case 3:
            return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(NSString *)tableView:(UITableView *)table_view titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"app.settings.profile.username.footer", "");
    }
    if (section == 1) {
        return NSLocalizedString(@"app.settings.profile.custom_status.footer", "");
    }
    if (section == 2) {
        return NSLocalizedString(@"app.settings.profile.socials.footer", "");
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    if (section == 0) {
        TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
        
        cell.delegate = self;
        [cell disableAutocapitalizationAndCorrection];
        [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.username.placeholder", "")];
        [cell setText:TO_NSSTRING(_profile->username)];
        return cell;
    }
    if (section == 1) {
        TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
        
        cell.delegate = self;
        [cell disableAutocapitalizationAndCorrection];;
        [cell setPlaceholder:NSLocalizedString(@"app.settings.custom_status.placeholder", "")];
        [cell setText:TO_NSSTRING(_profile->status)];
        return cell;
    }
    if (section == 2) {
        if (row == 0) {
            TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
            
            cell.delegate = self;
            [cell disableAutocapitalizationAndCorrection];
            [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.social_vkonakte.placeholder", "")];
            [cell setText:TO_NSSTRING(_profile->vk_page)];
            return cell;
        }
        if (row == 1) {
            TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
            
            cell.delegate = self;
            [cell disableAutocapitalizationAndCorrection];
            [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.social_telegram.placeholder", "")];
            [cell setText:TO_NSSTRING(_profile->telegram_page)];
            return cell;
        }
        if (row == 2) {
            TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
            
            cell.delegate = self;
            [cell disableAutocapitalizationAndCorrection];
            [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.social_discord.placeholder", "")];
            [cell setText:TO_NSSTRING(_profile->discord_page)];
            return cell;
        }
        if (row == 3) {
            TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
            
            cell.delegate = self;
            [cell disableAutocapitalizationAndCorrection];
            [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.social_instagram.placeholder", "")];
            [cell setText:TO_NSSTRING(_profile->instagram_page)];
            return cell;
        }
        if (row == 4) {
            TextFieldTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TextFieldTableViewCell getIdentifier]];
            
            cell.delegate = self;
            [cell disableAutocapitalizationAndCorrection];
            [cell setPlaceholder:NSLocalizedString(@"app.settings.profile.social_tiktok.placeholder", "")];
            [cell setText:TO_NSSTRING(_profile->tt_page)];
            return cell;
        }
    }
    if (section == 3) {
        PlainTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[PlainTableViewCell getIdentifier]];
        
        [cell setContent:NSLocalizedString(@"app.settings.profile.logout.text", "")];
        [cell setContentColor:[AppColorProvider alertColor]];
        return cell;
    }
    
    return nil;
}

-(NSString*)getToChangeFieldTextAtRow:(NSInteger)row section:(NSInteger)section {
    TextFieldTableViewCell* cell = [_content_table_view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return [cell isTextChanged] ? [cell getText] : nil;
}


-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    if (section == 3) {
        if (row == 0) {
            [self onLogoutSelected];
        }
    }
}

-(IBAction)onSaveBarButtonPressed:(UIBarButtonItem*)sender {
    _save_bar_button.enabled = NO;
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (self->_to_change_username) {
            api->profiles().change_login(TO_STDSTRING(self->_to_change_username));
            self->_to_change_username = nil;
        }
        if (self->_to_change_custom_status) {
            api->profiles().edit_status(TO_STDSTRING(self->_to_change_custom_status));
            self->_to_change_custom_status = nil;
        }
        
        anixart::ProfileSocial::Ptr social = api->profiles().get_profile_social(self->_profile->id);
        if (self->_to_change_social_vk) {
            social->vk_page = TO_STDSTRING(self->_to_change_social_vk);
            self->_to_change_social_vk = nil;
        }
        if (self->_to_change_social_tg) {
            social->telegram_page = TO_STDSTRING(self->_to_change_social_tg);
            self->_to_change_social_tg = nil;
        }
        if (self->_to_change_social_discord) {
            social->discord_page = TO_STDSTRING(self->_to_change_social_discord);
            self->_to_change_social_discord = nil;
        }
        if (self->_to_change_social_instagram) {
            social->instagram_page = TO_STDSTRING(self->_to_change_social_instagram);
            self->_to_change_social_instagram = nil;
        }
        if (self->_to_change_social_tiktok) {
            social->tiktok_page = TO_STDSTRING(self->_to_change_social_tiktok);
            self->_to_change_social_tiktok = nil;
        }
        api->profiles().edit_social(social);
        
        return YES;
    } withUICompletion:^{
        // TODO: notificate
    }];
}
-(void)textFieldViewCellDidBeginEditing:(TextFieldTableViewCell*)text_field_cell {
    
}
-(void)textFieldViewCellDidEndEditing:(TextFieldTableViewCell*)text_field_cell {
    if (![text_field_cell isTextChanged]) {
        return;
    }
    
    NSIndexPath* index_path = [_content_table_view indexPathForCell:text_field_cell];
    NSInteger section = index_path.section;
    NSInteger row = index_path.row;
    if (section == 0) {
        if (row == 0) {
            _to_change_username = [text_field_cell getText];
        }
    }
    if (section == 1) {
        if (row == 0) {
            _to_change_custom_status = [text_field_cell getText];
        }
    }
    if (section == 2) {
        if (row == 0) {
            _to_change_social_vk = [text_field_cell getText];
        }
        if (row == 1) {
            _to_change_social_tg = [text_field_cell getText];
        }
        if (row == 2) {
            _to_change_social_discord = [text_field_cell getText];
        }
        if (row == 3) {
            _to_change_social_instagram = [text_field_cell getText];
        }
        if (row == 4) {
            _to_change_social_tiktok = [text_field_cell getText];
        }
    }
    _save_bar_button.enabled = YES;
}
-(BOOL)textFieldViewCellShouldReturn:(TextFieldTableViewCell*)text_field_cell {
    [text_field_cell endEditing:YES];
    return NO;
}
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // TODO: cirle image picker overlay
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* image = info[UIImagePickerControllerEditedImage];
    NSURL* orig_image_url = info[UIImagePickerControllerImageURL];
    
    __block anixart::ProfilePreferenceStatus::Ptr edit_status;
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        NSURL* avatar_url = [NSURL URLWithString:@"ava.jpg" relativeToURL:orig_image_url.filePathURL];
        [UIImageJPEGRepresentation(image, 1.0) writeToURL:avatar_url atomically:YES];
        std::filesystem::path path = TO_STDSTRING([avatar_url path]);
        
        BOOL errored = NO;
        try {
            edit_status = api->profiles().edit_avatar(path);
        } catch (...) {
            errored = YES;
        }

        [[NSFileManager defaultManager] removeItemAtURL:avatar_url error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:orig_image_url error:nil];
        return errored;
    } withUICompletion:^{
        self->_profile->avatar_url = edit_status->avatar_url;
        [self reloadAvatar];
    }];
}

-(void)onAvatarPressed {
    if (!_image_picker_controller) {
        _image_picker_controller = [UIImagePickerController new];
        _image_picker_controller.delegate = self;
        _image_picker_controller.allowsEditing = YES;
    }
    [self presentViewController:_image_picker_controller animated:YES completion:nil];
}
-(void)onLogoutSelected {
    // TODO: don't set token and instead set is_logged_in
    [_app_data_controller setToken:@""];
    [_app_data_controller setMyProfileID:static_cast<anixart::ProfileID>(0)];
    
    MainWindow* main_window = (MainWindow*)[[[UIApplication sharedApplication] delegate] window];
    [main_window setRootViewController:[AuthViewController new]];
}

@end
