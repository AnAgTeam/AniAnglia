//
//  FilterViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.12.2024.
//

#import <Foundation/Foundation.h>
#import "FilterViewController.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "StringCvt.h"

@interface FilterViewController ()
@property(nonatomic, retain) UIButton* status_select_button;

@end

@implementation FilterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

-(void)setup {
    _status_select_button = [UIButton new];
    [self.view addSubview:_status_select_button];
    _status_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_status_select_button.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_status_select_button.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:5].active = YES;
    [_status_select_button.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor constant:-10].active = YES;
    [_status_select_button.heightAnchor constraintEqualToConstant:50].active = YES;
    [_status_select_button setTitle:NSLocalizedString(@"app.filter.status_select_button.menu.none.text", "") forState:UIControlStateNormal];
    auto release_status_name = [](libanixart::Release::Status status) {
        switch (status) {
            case libanixart::Release::Status::Unknown:
                return NSLocalizedString(@"app.filter.status_select_button.menu.none.text", "");
            case libanixart::Release::Status::Finished:
                return NSLocalizedString(@"app.filter.status_select_button.menu.finished.text", "");
            case libanixart::Release::Status::Ongoing:
                return NSLocalizedString(@"app.filter.status_select_button.menu.ongoing.text", "");
            case libanixart::Release::Status::Upcoming:
                return NSLocalizedString(@"app.filter.status_select_button.menu.upcoming.text", "");
        }
    };
    auto create_status_menu_action = [self, release_status_name](libanixart::Release::Status status) {
        return [UIAction actionWithTitle:release_status_name(status) image:nil identifier:nil handler:^(UIAction* action) {
            [self selectStatusMenuItemSelected:status];
        }];
    };
    UIMenu* status_menu = [UIMenu menuWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.title", "") children:@[
        create_status_menu_action(libanixart::Release::Status::Unknown),
        create_status_menu_action(libanixart::Release::Status::Finished),
        create_status_menu_action(libanixart::Release::Status::Ongoing),
        create_status_menu_action(libanixart::Release::Status::Upcoming)
    ]];
    [_status_select_button setMenu:status_menu];
    _status_select_button.showsMenuAsPrimaryAction = YES;
    
    [self setupLayout];
}
-(void)setupLayout {
    _status_select_button.layer.cornerRadius = 8;
    [_status_select_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _status_select_button.backgroundColor = [AppColorProvider foregroundColor1];
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)selectStatusMenuItemSelected:(libanixart::Release::Status)status {
    NSLog(@"selectStatusMenuItemSelected:%d", status);
}

@end
