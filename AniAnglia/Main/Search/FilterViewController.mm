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
#import "SearchViewController.h"
#import "ReleasesHistoryTableViewController.h"
#import "ReleasesTableViewController.h"

@class MultiSelectMenuModalViewController;

@protocol MultiSelectMenuButtonPresenter <NSObject>
-(void)presentMultiSelectViewController:(UIViewController*)view_controller;
@end

@protocol MultiSelectMenuModalViewControllerDelegate <NSObject>
-(void)multiSelectMenuModalViewControllerDonePressed:(MultiSelectMenuModalViewController*)multi_select_menu_modal_view_controller;
@end

@interface SingleSelectMenuAction : NSObject
@property(nonatomic, retain) NSString* title;
@property(nonatomic, copy) void(^handler)();

+(instancetype)actionWithTitle:(NSString*)title handler:(void(^)())handler;
-(instancetype)initWithTitle:(NSString*)title handler:(void(^)())handler;

-(void)callHandler;
@end

@interface MultiSelectMenuAction : NSObject
@property(nonatomic, retain) NSString* title;
@property(nonatomic, copy) void(^handler)(BOOL selected);
@property(nonatomic) BOOL selected;

+(instancetype)actionWithTitle:(NSString*)title handler:(void(^)(BOOL selected))handler;
-(instancetype)initWithTitle:(NSString*)title handler:(void(^)(BOOL selected))handler;

-(void)switchSelected;
-(void)callHandler;
@end

@interface SingleSelectMenuButton : UIView
@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) UILabel* label;
@property(nonatomic, retain) UIButton* button;
@property(nonatomic, retain, readonly) NSArray<SingleSelectMenuAction*>* actions;

-(instancetype)initWithTitle:(NSString*)title buttonMenuActions:(NSArray<SingleSelectMenuAction*>*)actions;

-(void)updateActions:(NSArray<SingleSelectMenuAction*>*)actions;
@end

@interface MultiSelectMenuButton : UIView
@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) UILabel* label;
@property(nonatomic, retain) UIButton* button;
@property(nonatomic, retain, readonly) NSArray<MultiSelectMenuAction*>* actions;
@property(nonatomic, weak) id<MultiSelectMenuButtonPresenter> presenter;

-(instancetype)initWithTitle:(NSString*)locale_title buttonMenuActions:(NSArray<MultiSelectMenuAction*>*)actions;

-(void)updateActions:(NSArray<MultiSelectMenuAction*>*)actions;
@end

@interface MultiSelectMenuModalTableViewCell : UITableViewCell
@property(nonatomic, retain) UIImageView* checkbox_image_view;
@property(nonatomic, retain) UILabel* name_label;

+(NSString*)getIdentifier;
-(void)setCheckboxed:(BOOL)selected;
-(void)setName:(NSString*)name;
@end

@interface MultiSelectMenuModalViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, retain) UIVisualEffectView* blur_effect_view;
@property(nonatomic, retain) UIView* content_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UITableView* actions_table_view;
@property(nonatomic, retain) UIButton* select_all_button;
@property(nonatomic, retain) UIButton* done_button;
@property(nonatomic, retain, readonly) NSArray<MultiSelectMenuAction*>* actions;
@property(nonatomic, retain) NSString* modal_title;
@property(nonatomic) NSInteger selected_count;
@property(nonatomic, retain) id<MultiSelectMenuModalViewControllerDelegate> delegate;

-(instancetype)initWithTitle:(NSString*)title actions:(NSArray<MultiSelectMenuAction*>*)actions;
-(void)updateActions:(NSArray<MultiSelectMenuAction*>*)actions;
@end

@interface FilterViewController () <MultiSelectMenuButtonPresenter> {
    anixart::requests::FilterRequest _filter_request;
    std::vector<anixart::EpisodeType::Ptr> _episode_types;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIScrollView* scroll_view;
@property(nonatomic, retain) UIStackView* stack_view;
@property(nonatomic, retain) SingleSelectMenuButton* status_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* category_select_button;
@property(nonatomic, retain) MultiSelectMenuButton* genres_select_button;
@property(nonatomic, retain) UIButton* genres_exclude_mode_button;
@property(nonatomic, retain) SingleSelectMenuButton* country_select_button;
@property(nonatomic, retain) MultiSelectMenuButton* types_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* studio_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* season_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* episode_count_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* episode_duration_select_button;
@property(nonatomic, retain) MultiSelectMenuButton* list_exclude_select_button;
@property(nonatomic, retain) MultiSelectMenuButton* age_rating_select_button;
@property(nonatomic, retain) SingleSelectMenuButton* sort_select_button;
@property(nonatomic, retain) UIButton* search_button;

@end

@implementation SingleSelectMenuAction

+(instancetype)actionWithTitle:(NSString*)title handler:(void(^)())handler {
    return [[SingleSelectMenuAction alloc] initWithTitle:title handler:handler];
}
-(instancetype)initWithTitle:(NSString*)title handler:(void(^)())handler {
    self = [super init];
    
    _handler = [handler copy];
    _title = title;
    
    return self;
}

-(void)callHandler {
    _handler();
}
@end

@implementation MultiSelectMenuAction
+(instancetype)actionWithTitle:(NSString*)title handler:(void(^)(BOOL selected))handler {
    return [[MultiSelectMenuAction alloc] initWithTitle:title handler:handler];
}
-(instancetype)initWithTitle:(NSString*)title handler:(void(^)(BOOL selected))handler {
    self = [super init];
    
    _handler = [handler copy];
    _title = title;
    
    return self;
}

-(void)switchSelected {
    _selected = !_selected;
}
-(void)callHandler {
    _handler(_selected);
}
@end

@implementation SingleSelectMenuButton
-(instancetype)initWithTitle:(NSString*)title buttonMenuActions:(NSArray<SingleSelectMenuAction*>*)actions {
    self = [super init];
    
    _title = title;
    _actions = actions;
    
    [self setupView];
    _label.text = title;
    [_label sizeToFit];
    [_button setTitle:actions[0].title forState:UIControlStateNormal];
    
    [self updateActions:actions];
    
    return self;
}

-(void)setupView {
    _label = [UILabel new];
    [self addSubview:_label];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [_label.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    
    _button = [UIButton new];
    [self addSubview:_button];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [_button.topAnchor constraintEqualToAnchor:_label.bottomAnchor].active = YES;
    [_button.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_button.heightAnchor constraintEqualToConstant:50].active = YES;
    _button.showsMenuAsPrimaryAction = YES;
    
    [self setupLayout];
}
-(void)setupLayout {
    _label.textColor = [AppColorProvider textColor];
    _button.layer.cornerRadius = 8;
    [_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _button.backgroundColor = [AppColorProvider foregroundColor1];
    self.backgroundColor = [UIColor clearColor];
}
-(void)updateActions:(NSArray<SingleSelectMenuAction*>*)actions {
    _actions = actions;
    NSMutableArray<UIAction*>* menu_actions = [NSMutableArray arrayWithCapacity:[actions count]];
    int i = 0;
    for (SingleSelectMenuAction* titled_action : actions) {
        menu_actions[i++] = [UIAction actionWithTitle:titled_action.title image:nil identifier:nil handler:^(UIAction* action) {
            [self.button setTitle:titled_action.title forState:UIControlStateNormal];
            [titled_action callHandler];
        }];
    }
    UIMenu* menu = [UIMenu menuWithTitle:actions[0].title children:menu_actions];
    [_button setMenu:menu];
}
@end

@implementation MultiSelectMenuButton
-(instancetype)initWithTitle:(NSString*)title buttonMenuActions:(NSArray<MultiSelectMenuAction*>*)actions {
    self = [super init];
    
    _title = title;
    _actions = actions;
    
    [self setupView];
    _label.text = title;
    [_label sizeToFit];
    
    [_button setTitle:title forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

-(void)setupView {
    _label = [UILabel new];
    [self addSubview:_label];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [_label.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    
    _button = [UIButton new];
    [self addSubview:_button];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [_button.topAnchor constraintEqualToAnchor:_label.bottomAnchor].active = YES;
    [_button.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [_button.heightAnchor constraintEqualToConstant:50].active = YES;
    _button.showsMenuAsPrimaryAction = YES;
    
    [self setupLayout];
}
-(void)setupLayout {
    _label.textColor = [AppColorProvider textColor];
    _button.layer.cornerRadius = 8;
    [_button setTitleColor:[AppColorProvider textColor] forState:UIControlStateNormal];
    _button.backgroundColor = [AppColorProvider foregroundColor1];
    self.backgroundColor = [UIColor clearColor];
}
-(void)updateActions:(NSArray<MultiSelectMenuAction*>*)actions {
    _actions = actions;
}

-(IBAction)onButtonPressed:(UIButton*)sender {
    MultiSelectMenuModalViewController* view_controller = [[MultiSelectMenuModalViewController alloc] initWithTitle:_title actions:_actions];
    
    [_presenter presentMultiSelectViewController:view_controller];
}
@end

@implementation MultiSelectMenuModalTableViewCell

+(NSString*)getIdentifier {
    return @"MultiSelectMenuModalTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _checkbox_image_view = [UIImageView new];
    _name_label = [UILabel new];
    _name_label.numberOfLines = 1;
    
    [self addSubview:_checkbox_image_view];
    [self addSubview:_name_label];
    
    _checkbox_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_checkbox_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_checkbox_image_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_checkbox_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_checkbox_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        
        [_name_label.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_name_label.trailingAnchor constraintEqualToAnchor:_checkbox_image_view.leadingAnchor constant:-5],
        [_name_label.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor]
    ]];
}

-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
    _checkbox_image_view.tintColor = [UIColor systemGrayColor];
    _name_label.textColor = [AppColorProvider textColor];
}

-(void)setCheckboxed:(BOOL)selected {
    if (selected) {
        _checkbox_image_view.image = [UIImage systemImageNamed:@"checkmark.square"];
        _checkbox_image_view.tintColor = [AppColorProvider primaryColor];
    } else {
        _checkbox_image_view.image = [UIImage systemImageNamed:@"square"];
        _checkbox_image_view.tintColor = [UIColor systemGrayColor];
    }
}
-(void)setName:(NSString*)name {
    _name_label.text = name;
}

@end

@implementation MultiSelectMenuModalViewController

-(instancetype)initWithTitle:(NSString *)title actions:(NSArray<MultiSelectMenuAction*>*)actions {
    self = [super init];
    
    _selected_count = 0;
    _actions = actions;
    _modal_title = title;
    
    for (MultiSelectMenuAction* action : _actions) {
        if (action.selected) {
            _selected_count++;
        }
    }
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    _blur_effect_view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    _blur_effect_view.alpha = 0.92;
    _content_view = [UIView new];
    _content_view.layoutMargins = UIEdgeInsetsMake(12, 12, 12, 12);
    _content_view.layer.cornerRadius = 12;
    _title_label = [UILabel new];
    _title_label.numberOfLines = 1;
    _title_label.text = _modal_title;
    _actions_table_view = [UITableView new];
    _actions_table_view.delegate = self;
    _actions_table_view.dataSource = self;
    [_actions_table_view registerClass:MultiSelectMenuModalTableViewCell.class forCellReuseIdentifier:[MultiSelectMenuModalTableViewCell getIdentifier]];
    _actions_table_view.layer.cornerRadius = 8;
    _select_all_button = [UIButton new];
    [_select_all_button addTarget:self action:@selector(onSelectAllPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_select_all_button setImage:[UIImage systemImageNamed:@"square"] forState:UIControlStateNormal];
    _select_all_button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _select_all_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _done_button = [UIButton new];
    [_done_button addTarget:self action:@selector(onDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_done_button setTitle:NSLocalizedString(@"app.filter.multi_select._modal.done_button.title", "") forState:UIControlStateNormal];
    _done_button.layer.cornerRadius = 8;
    
    [self.view addSubview:_blur_effect_view];
    [self.view addSubview:_content_view];
    [self.view addSubview:_title_label];
    [self.view addSubview:_select_all_button];
    [self.view addSubview:_actions_table_view];
    [self.view addSubview:_done_button];
    
    _blur_effect_view.translatesAutoresizingMaskIntoConstraints = NO;
    _content_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _actions_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _select_all_button.translatesAutoresizingMaskIntoConstraints = NO;
    _done_button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_blur_effect_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_blur_effect_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_blur_effect_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_blur_effect_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [_content_view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_content_view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [_content_view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.75],
        [_content_view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.65],
        
        [_select_all_button.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_select_all_button.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor constant:-16],
        [_select_all_button.widthAnchor constraintEqualToConstant:28],
        [_select_all_button.heightAnchor constraintEqualToConstant:25],
        
        [_title_label.topAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.leadingAnchor],
        [_title_label.trailingAnchor constraintEqualToAnchor:_select_all_button.leadingAnchor],
        [_title_label.bottomAnchor constraintEqualToAnchor:_select_all_button.bottomAnchor],
        
        [_done_button.bottomAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.bottomAnchor],
        [_done_button.leadingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.leadingAnchor],
        [_done_button.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        [_done_button.heightAnchor constraintEqualToConstant:50],
        
        [_actions_table_view.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor constant:10],
        [_actions_table_view.leadingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.leadingAnchor],
        [_actions_table_view.trailingAnchor constraintEqualToAnchor:_content_view.layoutMarginsGuide.trailingAnchor],
        [_actions_table_view.bottomAnchor constraintEqualToAnchor:_done_button.topAnchor constant:-10]
    ]];
}
-(void)setupLayout {
    self.view.backgroundColor = [UIColor clearColor];
    _content_view.backgroundColor = [AppColorProvider backgroundColor];
    _title_label.textColor = [AppColorProvider textColor];
    _actions_table_view.backgroundColor = [AppColorProvider foregroundColor1];
    [self updateSelectedCount];
    _done_button.backgroundColor = [AppColorProvider primaryColor];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_actions count];
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 50;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    MultiSelectMenuModalTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[MultiSelectMenuModalTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    MultiSelectMenuAction* action = _actions[index];

    [cell setName:action.title];
    [cell setCheckboxed:action.selected];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    MultiSelectMenuModalTableViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    MultiSelectMenuAction* action = _actions[index];
    
    [action switchSelected];
    if (action.selected) {
        _selected_count++;
    } else {
        _selected_count--;
    }
    [self updateSelectedCount];
    
    [cell setCheckboxed:action.selected];
    [action callHandler];
}

-(IBAction)onSelectAllPressed:(UIButton*)sender {
    BOOL to_be_selected = _selected_count < [_actions count];
    _selected_count = to_be_selected ? [_actions count] : 0;
    
    for (size_t i = 0; i < [_actions count]; ++i) {
        MultiSelectMenuAction* action = _actions[i];
        
        BOOL was_selected = action.selected;
        action.selected = to_be_selected;
        if (was_selected != to_be_selected) {
            [action callHandler];
        }
    }
    [_actions_table_view reloadData];
    [self updateSelectedCount];
}
-(IBAction)onDoneButtonPressed:(UIButton*)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate multiSelectMenuModalViewControllerDonePressed:self];
}

-(void)updateSelectedCount {
    if (_selected_count <= 0) {
        [_select_all_button setImage:[UIImage systemImageNamed:@"square"] forState:UIControlStateNormal];
        _select_all_button.tintColor = [UIColor systemGrayColor];
    }
    else if (_selected_count >= [_actions count]) {
        [_select_all_button setImage:[UIImage systemImageNamed:@"checkmark.square"] forState:UIControlStateNormal];
        _select_all_button.tintColor = [AppColorProvider primaryColor];
    }
    else {
        [_select_all_button setImage:[UIImage systemImageNamed:@"dot.square"] forState:UIControlStateNormal];
        _select_all_button.tintColor = [AppColorProvider primaryColor];
    }
}

-(void)updateActions:(NSArray<MultiSelectMenuAction*>*)actions {
    // TODO
}

@end

@implementation FilterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _scroll_view = [UIScrollView new];
    _scroll_view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _stack_view = [UIStackView new];
    _stack_view.distribution = UIStackViewDistributionEqualSpacing;
    _stack_view.axis = UILayoutConstraintAxisVertical;
    _stack_view.alignment = UIStackViewAlignmentFill;
    _stack_view.spacing = 15;
    _stack_view.clipsToBounds = YES;
    _stack_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 15, 0, 15);
    _stack_view.layoutMarginsRelativeArrangement = YES;
    
    _status_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.none.text", "") handler:^{
            [self onStatusMenuItemSelected:anixart::Release::Status::Unknown];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.finished.text", "") handler:^{
            [self onStatusMenuItemSelected:anixart::Release::Status::Finished];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.ongoing.text", "") handler:^{
            [self onStatusMenuItemSelected:anixart::Release::Status::Ongoing];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.status_select_button.menu.upcoming.text", "") handler:^{
            [self onStatusMenuItemSelected:anixart::Release::Status::Upcoming];
        }]
    ]];

    _category_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.category_select_button.menu.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.category_select_button.menu.none.text", "") handler:^{
            [self onCategoryMenuItemSelected:anixart::Release::Category::Unknown];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.category_select_button.menu.series.text", "") handler:^{
            [self onCategoryMenuItemSelected:anixart::Release::Category::Series];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.category_select_button.menu.movies.text", "") handler:^{
            [self onCategoryMenuItemSelected:anixart::Release::Category::Movies];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.category_select_button.menu.ova.text", "") handler:^{
            [self onCategoryMenuItemSelected:anixart::Release::Category::Ova];
        }]
    ]];
    _genres_select_button = [[MultiSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.genres_select_button.menu.title", "") buttonMenuActions:[self createGenreActions]];
    _genres_exclude_mode_button = [UIButton new];
    [_genres_exclude_mode_button setImage:[UIImage systemImageNamed:@"square.slash"] forState:UIControlStateNormal];
    [_genres_exclude_mode_button addTarget:self action:@selector(onGenresExcludeModePressed:) forControlEvents:UIControlEventTouchUpInside];
    _genres_exclude_mode_button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _genres_exclude_mode_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    
    _country_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.country_select_button.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.country_select_button.menu.none.text", "") handler:^{
            [self onCountryMenuItemSelected:nil];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.country_select_button.menu.japan.text", "") handler:^{
            [self onCountryMenuItemSelected:@"Япония"];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.country_select_button.menu.china.text", "") handler:^{
            [self onCountryMenuItemSelected:@"Китай"];
        }]
    ]];
    _types_select_button = [[MultiSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.types_select_button.menu.title", "") buttonMenuActions:@[]];
    _studio_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.studio_select_button.title", "") buttonMenuActions:[self createStudioActions]];
    _season_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.season_select_button.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.season_select_button.menu.none.text", "") handler:^{
        [self onSeasonMenuItemSelected:anixart::Release::Season::Unknown];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.season_select_button.menu.winter.text", "") handler:^{
        [self onSeasonMenuItemSelected:anixart::Release::Season::Winter];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.season_select_button.menu.spring.text", "") handler:^{
        [self onSeasonMenuItemSelected:anixart::Release::Season::Spring];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.season_select_button.menu.summer.text", "") handler:^{
        [self onSeasonMenuItemSelected:anixart::Release::Season::Summer];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.season_select_button.menu.fall.text", "") handler:^{
            [self onSeasonMenuItemSelected:anixart::Release::Season::Fall];
        }]
    ]];
    _episode_count_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.menu.none.text", "") handler:^{
            [self onEpisodeCountMenuItemSelected:0];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.menu.1_to_12.text", "") handler:^{
            [self onEpisodeCountMenuItemSelected:1];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.menu.13_to_24.text", "") handler:^{
            [self onEpisodeCountMenuItemSelected:2];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.menu.25_to_100.text", "") handler:^{
            [self onEpisodeCountMenuItemSelected:3];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_count_select_button.menu.100_plus.text", "") handler:^{
            [self onEpisodeCountMenuItemSelected:4];
        }]
    ]];
    _episode_duration_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.episode_duration_select_button.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_duration_select_button.menu.none.text", "") handler:^{
            [self onEpisodeDurationMenuItemSelected:0];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_duration_select_button.menu.to_10.text", "") handler:^{
            [self onEpisodeDurationMenuItemSelected:1];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_duration_select_button.menu.to_30.text", "") handler:^{
            [self onEpisodeDurationMenuItemSelected:2];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.episode_duration_select_button.menu.30_plus.text", "") handler:^{
            [self onEpisodeDurationMenuItemSelected:3];
        }]
    ]];
    _list_exclude_select_button = [[MultiSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.title", "") buttonMenuActions:@[
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.favorite", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::Favorite selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.watching", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::Watching selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.plan", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::Plan selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.watched", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::Watched selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.hold_on", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::HoldOn selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.list_exclude_select_button.menu.dropped", "") handler:^(BOOL selected) {
            [self onProfileListExlusionMenuItemSelected:anixart::Profile::List::Dropped selected:selected];
        }]
    ]];
    _age_rating_select_button = [[MultiSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.title", "") buttonMenuActions:@[
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.g", "") handler:^(BOOL selected) {
            [self onAgeRatingMenuItemSelected:anixart::Release::AgeRating::G selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.pg6", "") handler:^(BOOL selected) {
        [self onAgeRatingMenuItemSelected:anixart::Release::AgeRating::PG6 selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.pg12", "") handler:^(BOOL selected) {
        [self onAgeRatingMenuItemSelected:anixart::Release::AgeRating::PG12 selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.r16", "") handler:^(BOOL selected) {
        [self onAgeRatingMenuItemSelected:anixart::Release::AgeRating::R16 selected:selected];
        }],
        [MultiSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.age_rating_select_button.menu.r18", "") handler:^(BOOL selected) {
        [self onAgeRatingMenuItemSelected:anixart::Release::AgeRating::R18 selected:selected];
        }]
    ]];
    _sort_select_button = [[SingleSelectMenuButton alloc] initWithTitle:NSLocalizedString(@"app.filter.sort_select_button.title", "") buttonMenuActions:@[
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.sort_select_button.menu.release_date.text", "") handler:^{
            [self onSortSelectMenuItemSelected:anixart::requests::FilterRequest::Sort::DateUpdate];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.sort_select_button.menu.grade.text", "") handler:^{
        [self onSortSelectMenuItemSelected:anixart::requests::FilterRequest::Sort::Grade];
        }],
        [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.sort_select_button.menu.year.text", "") handler:^{
        [self onSortSelectMenuItemSelected:anixart::requests::FilterRequest::Sort::Year];
        }]
    ]];
    _search_button = [UIButton new];
    [_search_button setTitle:NSLocalizedString(@"app.filter.search_button.title", "") forState:UIControlStateNormal];
    [_search_button addTarget:self action:@selector(onSearchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _search_button.layer.cornerRadius = 8;
    
    _genres_select_button.presenter = self;
    _types_select_button.presenter = self;
    _list_exclude_select_button.presenter = self;
    _age_rating_select_button.presenter = self;
    
    [self.view addSubview:_scroll_view];
    [_scroll_view addSubview:_stack_view];
    [_stack_view addArrangedSubview:_status_select_button];
    [_stack_view addArrangedSubview:_category_select_button];
    [_stack_view addArrangedSubview:_genres_select_button];
    [_genres_select_button.button addSubview:_genres_exclude_mode_button];
    [_stack_view addArrangedSubview:_country_select_button];
    [_stack_view addArrangedSubview:_types_select_button];
    [_stack_view addArrangedSubview:_studio_select_button];
    [_stack_view addArrangedSubview:_season_select_button];
    [_stack_view addArrangedSubview:_episode_count_select_button];
    [_stack_view addArrangedSubview:_episode_duration_select_button];
    [_stack_view addArrangedSubview:_list_exclude_select_button];
    [_stack_view addArrangedSubview:_age_rating_select_button];
    [_stack_view addArrangedSubview:_sort_select_button];
    [_stack_view addArrangedSubview:_search_button];
    
    _scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _stack_view.translatesAutoresizingMaskIntoConstraints = NO;
    _status_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _category_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _genres_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _genres_exclude_mode_button.translatesAutoresizingMaskIntoConstraints = NO;
    _country_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _types_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _studio_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _season_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _episode_count_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _episode_duration_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _list_exclude_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _age_rating_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _sort_select_button.translatesAutoresizingMaskIntoConstraints = NO;
    _search_button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_scroll_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_scroll_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [_stack_view.topAnchor constraintEqualToAnchor:_scroll_view.topAnchor constant:10],
        [_stack_view.leadingAnchor constraintEqualToAnchor:_scroll_view.leadingAnchor],
        [_stack_view.trailingAnchor constraintEqualToAnchor:_scroll_view.trailingAnchor],
        [_stack_view.bottomAnchor constraintEqualToAnchor:_scroll_view.bottomAnchor constant:-10],
        [_stack_view.widthAnchor constraintEqualToAnchor:_scroll_view.widthAnchor],
        [_stack_view.heightAnchor constraintGreaterThanOrEqualToAnchor:_scroll_view.heightAnchor],
        
        [_status_select_button.bottomAnchor constraintEqualToAnchor:_status_select_button.button.bottomAnchor],
        [_category_select_button.bottomAnchor constraintEqualToAnchor:_category_select_button.button.bottomAnchor],
        [_genres_select_button.bottomAnchor constraintEqualToAnchor:_genres_select_button.button.bottomAnchor],
        [_country_select_button.bottomAnchor constraintEqualToAnchor:_country_select_button.button.bottomAnchor],
        [_types_select_button.bottomAnchor constraintEqualToAnchor:_types_select_button.button.bottomAnchor],
        [_studio_select_button.bottomAnchor constraintEqualToAnchor:_studio_select_button.button.bottomAnchor],
        [_season_select_button.bottomAnchor constraintEqualToAnchor:_season_select_button.button.bottomAnchor],
        [_episode_count_select_button.bottomAnchor constraintEqualToAnchor:_episode_count_select_button.button.bottomAnchor],
        [_episode_duration_select_button.bottomAnchor constraintEqualToAnchor:_episode_duration_select_button.button.bottomAnchor],
        [_list_exclude_select_button.bottomAnchor constraintEqualToAnchor:_list_exclude_select_button.button.bottomAnchor],
        [_age_rating_select_button.bottomAnchor constraintEqualToAnchor:_age_rating_select_button.button.bottomAnchor],
        [_sort_select_button.bottomAnchor constraintEqualToAnchor:_sort_select_button.button.bottomAnchor],
        
        [_genres_exclude_mode_button.centerYAnchor constraintEqualToAnchor:_genres_select_button.button.layoutMarginsGuide.centerYAnchor],
        [_genres_exclude_mode_button.trailingAnchor constraintEqualToAnchor:_genres_select_button.button.layoutMarginsGuide.trailingAnchor],
        [_genres_exclude_mode_button.widthAnchor constraintEqualToAnchor:_genres_select_button.button.layoutMarginsGuide.heightAnchor],
        [_genres_exclude_mode_button.heightAnchor constraintEqualToAnchor:_genres_select_button.button.layoutMarginsGuide.heightAnchor],
        [_search_button.heightAnchor constraintEqualToConstant:50],
    ]];
    
    [self tryLoadEpisodeTypes];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    _search_button.backgroundColor = [AppColorProvider primaryColor];
    [self updateGenresExcludeButton];
}
-(NSArray<MultiSelectMenuAction*>*)createGenreActions {
    NSArray<NSString*>* genres = [_api_proxy getGenresArray];
    NSMutableArray<MultiSelectMenuAction*>* actions = [NSMutableArray arrayWithCapacity:[genres count]];
    for (size_t i = 0; i < [genres count]; ++i) {
        actions[i] = [MultiSelectMenuAction actionWithTitle:genres[i] handler:^(BOOL selected) {
            [self onGenresMenuItemSelectedAtIndex:i selected:selected];
        }];
    }
    return actions;
}
-(NSArray<SingleSelectMenuAction*>*)createStudioActions {
    NSArray<NSString*>* studios = [_api_proxy getStudiosArray];
    NSMutableArray<SingleSelectMenuAction*>* actions = [NSMutableArray arrayWithCapacity:1 + [studios count]];
    actions[0] = [SingleSelectMenuAction actionWithTitle:NSLocalizedString(@"app.filter.studio_select_button.menu.none.text", "") handler:^{
        [self onStudioMenuItemSelectedAtIndex:0];
    }];
    for (size_t i = 0; i < [studios count]; ++i) {
        actions[1 + i] = [SingleSelectMenuAction actionWithTitle:studios[i] handler:^{
            [self onStudioMenuItemSelectedAtIndex:1 + i];
        }];
    }
    return actions;
}

-(void)tryLoadEpisodeTypes {
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        self->_episode_types = api->episodes().get_all_types();
        return YES;
    } withUICompletion:^{
        [self updateTypesButtonActions];
    }];
}
-(void)updateTypesButtonActions {
    NSMutableArray<MultiSelectMenuAction*>* actions = [NSMutableArray arrayWithCapacity:_episode_types.size()];
    for (size_t i = 0; i < _episode_types.size(); ++i) {
        actions[i] = [MultiSelectMenuAction actionWithTitle:TO_NSSTRING(_episode_types[i]->name) handler:^(BOOL selected) {
            [self onTypeMenuItemSelectedAtIndex:i selected:selected];
        }];
    }
    [_types_select_button updateActions:actions];
}
-(void)updateGenresExcludeButton {
    if (_filter_request.is_genres_exclude_mode) {
        _genres_exclude_mode_button.tintColor = [AppColorProvider primaryColor];
    } else {
        _genres_exclude_mode_button.tintColor = [UIColor systemGrayColor];
    }
}

-(void)presentMultiSelectViewController:(UIViewController*)view_controller {
    [self presentViewController:view_controller animated:YES completion:nil];
}

-(void)onStatusMenuItemSelected:(anixart::Release::Status)status {
    if (status == anixart::Release::Status::Unknown) {
        _filter_request.status = std::nullopt;
        return;
    }
    _filter_request.status = status;
}
-(void)onCategoryMenuItemSelected:(anixart::Release::Category)category {
    if (category == anixart::Release::Category::Unknown) {
        _filter_request.category = std::nullopt;
        return;
    }
    _filter_request.category = category;
}
-(void)onCountryMenuItemSelected:(NSString*)country {
    if (country == nil) {
        _filter_request.country = std::nullopt;
        return;
    }
    _filter_request.country = TO_STDSTRING(country);
}
-(void)onStudioMenuItemSelectedAtIndex:(size_t)index {
    if (index == 0) {
        _filter_request.studio = std::nullopt;
        return;
    }
    NSArray<NSString*>* studios = [_api_proxy getStudiosArray];
    _filter_request.studio = TO_STDSTRING(studios[index - 1]);
}
-(void)onSeasonMenuItemSelected:(anixart::Release::Season)season {
    if (season == anixart::Release::Season::Unknown) {
        _filter_request.season = std::nullopt;
        return;
    }
    _filter_request.season = season;
}
-(void)onEpisodeCountMenuItemSelected:(NSInteger)count_index {
    if (count_index == 0) {
        _filter_request.episodes_count_from = std::nullopt;
        _filter_request.episodes_count_to = std::nullopt;
        return;
    }
    switch (count_index) {
        case 1:
            _filter_request.episodes_count_from = std::nullopt;
            _filter_request.episodes_count_to = 12;
            break;
        case 2:
            _filter_request.episodes_count_from = 13;
            _filter_request.episodes_count_to = 24;
            break;
        case 3:
            _filter_request.episodes_count_from = 25;
            _filter_request.episodes_count_to = 100;
            break;
        case 4:
            _filter_request.episodes_count_from = 101;
            _filter_request.episodes_count_to = std::nullopt;
            break;
    }
}
-(void)onEpisodeDurationMenuItemSelected:(NSInteger)duration_index {
    if (duration_index == 0) {
        _filter_request.episode_duration_from = std::nullopt;
        _filter_request.episode_duration_to = std::nullopt;
        return;
    }
    switch (duration_index) {
        case 1:
            _filter_request.episode_duration_from = std::nullopt;
            _filter_request.episode_duration_to = std::chrono::minutes(10);
            break;
        case 2:
            _filter_request.episode_duration_from = std::nullopt;
            _filter_request.episode_duration_to = std::chrono::minutes(30);
            break;
        case 3:
            _filter_request.episode_duration_from = std::chrono::minutes(30);
            _filter_request.episode_duration_to = std::nullopt;
            break;
    }
}
-(void)onSortSelectMenuItemSelected:(anixart::requests::FilterRequest::Sort)sort {
    _filter_request.sort = sort;
}

-(void)onGenresMenuItemSelectedAtIndex:(size_t)index selected:(BOOL)selected {
    NSArray<NSString*>* genres = [_api_proxy getGenresArray];
    std::string selected_genre = TO_STDSTRING(genres[index]);
    if (selected) {
        _filter_request.genres.push_back(selected_genre);
        return;
    }
    std::erase_if(_filter_request.genres, [&selected_genre](const std::string& genre) {
        return genre == selected_genre;
    });
}
-(void)onTypeMenuItemSelectedAtIndex:(size_t)index selected:(BOOL)selected {
    anixart::EpisodeTypeID selected_episode_type_id = _episode_types[index]->id;
    if (selected) {
        _filter_request.types.push_back(selected_episode_type_id);
        return;
    }
    std::erase_if(_filter_request.types, [&selected_episode_type_id](const anixart::EpisodeTypeID& episode_type_id) {
        return episode_type_id == selected_episode_type_id;
    });
}
-(void)onProfileListExlusionMenuItemSelected:(anixart::Profile::List)profile_list selected:(BOOL)selected {
    if (selected) {
        _filter_request.profile_list_exclusions.push_back(profile_list);
        return;
    }
    std::erase_if(_filter_request.profile_list_exclusions, [&profile_list](const anixart::Profile::List& list) {
        return list == profile_list;
    });
}
-(void)onAgeRatingMenuItemSelected:(anixart::Release::AgeRating)age_rating selected:(BOOL)selected {
    if (selected) {
        _filter_request.age_ratings.push_back(age_rating);
        return;
    }
    std::erase_if(_filter_request.age_ratings, [&age_rating](const anixart::Release::AgeRating& rating) {
        return rating == age_rating;
    });
}

-(IBAction)onGenresExcludeModePressed:(UIButton*)sender {
    _filter_request.is_genres_exclude_mode = !_filter_request.is_genres_exclude_mode;
    [self updateGenresExcludeButton];
}
-(IBAction)onSearchButtonPressed:(UIButton*)sender {
    anixart::FilterPages::UPtr pages = _api_proxy.api->search().filter_search(_filter_request, false, 0);
    
    ReleasesTableViewController* releases_view_controller = [[ReleasesTableViewController alloc] initWithPages:std::move(pages)];
    SearchViewController* search_view_controller = [[SearchViewController alloc] initWithContentViewController:releases_view_controller];
    search_view_controller.hide_search_bar = YES;
    
    [self.navigationController pushViewController:search_view_controller animated:YES];
}

@end
