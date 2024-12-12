//
//  ReleaseViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 29.08.2024.
//

#import <Foundation/Foundation.h>
#import "ReleaseViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "StringCvt.h"
#import "TypeSelectViewController.h"
#import "LoadableView.h"

@interface ReleaseViewController ()
@property(nonatomic) NSInteger release_id;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic) libanixart::Release::Ptr release_info;

@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) LoadableView* content_view;
@property(nonatomic, retain) LoadableImageView* release_image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* orig_title_label;
@property(nonatomic, retain) UIButton* add_list_button;
@property(nonatomic, retain) UIButton* bookmark_button;
@property(nonatomic, retain) UIButton* play_button;
@end

@implementation ReleaseViewController
static auto RELEASE_LIST_STATES = @[
    NSLocalizedString(@"app.release.state.none.title", ""),
    NSLocalizedString(@"app.release.state.watching.title", ""),
    NSLocalizedString(@"app.release.state.plan.title", ""),
    NSLocalizedString(@"app.release.state.watched.title", ""),
    NSLocalizedString(@"app.release.state.deffered.title", ""),
    NSLocalizedString(@"app.release.state.dropped.title", "")
];

NSString* profile_list_status_name(libanixart::ProfileList::Status status) {
    switch (status) {
        case libanixart::ProfileList::Status::NotWatching:
            return NSLocalizedString(@"app.release.state.none.title", "");
        case libanixart::ProfileList::Status::Watching:
            return NSLocalizedString(@"app.release.state.watching.title", "");
        case libanixart::ProfileList::Status::Plan:
            return NSLocalizedString(@"app.release.state.plan.title", "");
        case libanixart::ProfileList::Status::Watched:
            return NSLocalizedString(@"app.release.state.watched.title", "");
        case libanixart::ProfileList::Status::HoldOn:
            return NSLocalizedString(@"app.release.state.deffered.title", "");
        case libanixart::ProfileList::Status::Dropped:
            return NSLocalizedString(@"app.release.state.dropped.title", "");
    }
};

-(instancetype)initWithReleaseID:(NSInteger)release_id {
    self = [super init];
    
    self.release_id = release_id;
    self.api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)loadReleaseInfo {
    [self->_content_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(libanixart::Api* api) {
        self->_release_info = self->_api_proxy.api->releases().get_release(self->_release_id);
        return YES;
    } withUICompletion:^{
        [self->_content_view endLoading];
        [self setupReleaseView];
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupView];
}

-(void)setupView {
    _scroll_view = [UIScrollView new];
    [self.view addSubview:_scroll_view];
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_scroll_view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_scroll_view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    
    _content_view = [LoadableView new];
    [_scroll_view addSubview:_content_view];
    _content_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_content_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor].active = YES;
    NSLayoutConstraint* hconst = [_content_view.heightAnchor constraintEqualToAnchor:_scroll_view.heightAnchor];
    hconst.active = YES;
    hconst.priority = UILayoutPriority(50);
    [_content_view.leftAnchor constraintEqualToAnchor:_scroll_view.leftAnchor].active = YES;
    [_content_view.rightAnchor constraintEqualToAnchor:_scroll_view.rightAnchor].active = YES;
    [_content_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor].active = YES;
    [_content_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor].active = YES;
    
    [self preSetupLayout];
    
    if (_release_info) {
        [self setupReleaseView];
    }
    else {
        [self loadReleaseInfo];
    }
}

-(void)setupReleaseView {
    _release_image_view = [LoadableImageView new];
    [_content_view addSubview:_release_image_view];
    _release_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_release_image_view.topAnchor constraintEqualToAnchor:_content_view.topAnchor].active = YES;
    [_release_image_view.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor multiplier:0.6].active = YES;
    [_release_image_view.heightAnchor constraintEqualToAnchor:_content_view.widthAnchor multiplier:0.9].active = YES;
    [_release_image_view.centerXAnchor constraintEqualToAnchor:_content_view.centerXAnchor].active = YES;
    _release_image_view.layer.cornerRadius = 8.0;
    _release_image_view.layer.masksToBounds = YES;
    
    _title_label = [UILabel new];
    [_content_view addSubview:_title_label];
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_title_label.topAnchor constraintEqualToAnchor:_release_image_view.bottomAnchor constant:10].active = YES;
    [_title_label.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor constant:-80].active = YES;
    [_title_label.heightAnchor constraintLessThanOrEqualToConstant:70].active = YES;
    [_title_label.centerXAnchor constraintEqualToAnchor:_content_view.centerXAnchor].active = YES;
    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 0;
    _title_label.text = TO_NSSTRING(_release_info->title_ru);
    [_title_label setFont:[UIFont boldSystemFontOfSize:22]];
    [_title_label sizeToFit];
    
    _orig_title_label = [UILabel new];
    [_content_view addSubview:_orig_title_label];
    _orig_title_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_orig_title_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:2].active = YES;
    [_orig_title_label.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor constant:-80].active = YES;
    [_orig_title_label.heightAnchor constraintLessThanOrEqualToConstant:50].active = YES;
    [_orig_title_label.centerXAnchor constraintEqualToAnchor:_content_view.centerXAnchor].active = YES;
    _orig_title_label.textAlignment = NSTextAlignmentJustified;
    _orig_title_label.numberOfLines = 0;
    _orig_title_label.text = TO_NSSTRING(_release_info->title_original);
    [_orig_title_label sizeToFit];
    
    _add_list_button = [UIButton new];
    [_content_view addSubview:_add_list_button];
    _add_list_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_add_list_button.topAnchor constraintEqualToAnchor:_orig_title_label.bottomAnchor constant:10].active = YES;
    [_add_list_button.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor multiplier:0.3].active = YES;
    [_add_list_button.heightAnchor constraintEqualToConstant:30].active = YES;
    [_add_list_button.leadingAnchor constraintEqualToAnchor:_content_view.leadingAnchor constant:25].active = YES;
    [_add_list_button setTitle:profile_list_status_name(_release_info->profile_list_status) forState:UIControlStateNormal];
    [_add_list_button setImage:[UIImage systemImageNamed:@"chevron.down"] forState:UIControlStateNormal];
    
    auto create_list_menu_action = [self](libanixart::ProfileList::Status status) {
        return [UIAction actionWithTitle:profile_list_status_name(status) image:nil identifier:nil handler:^(UIAction* action){
            [self addListMenuSelected:status];
        }];
    };
    UIMenu* add_list_menu = [UIMenu menuWithTitle:NSLocalizedString(@"app.release.add_list_button.menu.title", "") children:@[
        create_list_menu_action(libanixart::ProfileList::Status::NotWatching),
        create_list_menu_action(libanixart::ProfileList::Status::Watching),
        create_list_menu_action(libanixart::ProfileList::Status::Plan),
        create_list_menu_action(libanixart::ProfileList::Status::Watched),
        create_list_menu_action(libanixart::ProfileList::Status::HoldOn),
        create_list_menu_action(libanixart::ProfileList::Status::Dropped)
    ]];
    [_add_list_button setMenu:add_list_menu];
    _add_list_button.showsMenuAsPrimaryAction = YES;
//    _add_list_button.layer.borderWidth = 0.6;
    _add_list_button.layer.cornerRadius = 8.0;
    
    _bookmark_button = [UIButton new];
    [_content_view addSubview:_bookmark_button];
    _bookmark_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_bookmark_button.topAnchor constraintEqualToAnchor:_add_list_button.topAnchor].active = YES;
    [_bookmark_button.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor multiplier:0.25].active = YES;
    [_bookmark_button.heightAnchor constraintEqualToConstant:30].active = YES;
    [_bookmark_button.leadingAnchor constraintEqualToAnchor:_add_list_button.trailingAnchor constant:15].active = YES;
    [_bookmark_button setTitle:[@(_release_info->favorite_count) stringValue] forState:UIControlStateNormal];
    _bookmark_button.layer.borderWidth = 0.6;
    _bookmark_button.layer.cornerRadius = 8.0;
    
    _play_button = [UIButton new];
    [_content_view addSubview:_play_button];
    _play_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_play_button.topAnchor constraintEqualToAnchor:_add_list_button.bottomAnchor constant:7].active = YES;
    [_play_button.widthAnchor constraintEqualToAnchor:_content_view.widthAnchor constant:-20].active = YES;
    [_play_button.heightAnchor constraintEqualToConstant:50].active = YES;
    [_play_button.leadingAnchor constraintEqualToAnchor:_content_view.leadingAnchor constant:10].active = YES;
    [_play_button setTitle:NSLocalizedString(@"app.release.play_button.title", "") forState:UIControlStateNormal];
    _play_button.layer.cornerRadius = 9.0;
    [_play_button addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_content_view.bottomAnchor constraintEqualToAnchor:_play_button.bottomAnchor].active = YES;
    
    [_release_image_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(_release_info->image_url)]];
    
    [self setupLayout];
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _title_label.textColor = [AppColorProvider textColor];
    _orig_title_label.textColor = [AppColorProvider textColor];
    _add_list_button.backgroundColor = [AppColorProvider foregroundColor1];
    [_add_list_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _bookmark_button.layer.borderColor = [AppColorProvider foregroundColor1].CGColor;
    [_bookmark_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _play_button.backgroundColor = [AppColorProvider primaryColor];
    [_play_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
}

-(void)addListMenuSelected:(libanixart::ProfileList::Status)status {
    NSLog(@"addListMenuSelected: %d", status);
}

-(IBAction)playButtonPressed:(id)sender {
    self.navigationController.toolbarHidden = NO;
    [self.navigationController pushViewController:[[TypeSelectViewController alloc] initWithReleaseID:_release_info->id] animated:YES];
}

@end
