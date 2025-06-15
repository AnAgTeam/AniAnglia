//
//  HistoryTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesSearchHistoryTableViewController.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface ReleasesSearchHistoryTableViewCell : UITableViewCell
@property(nonatomic, retain) UIImageView* magnifier_image_view;
@property(nonatomic, retain) UILabel* history_item_label;

+(NSString*)getIdentifier;
-(void)setHistoryText:(NSString*)text;
-(NSString*)getHistoryText;
@end

@interface ReleasesSearchHistoryTableViewController ()
@property(nonatomic) AppDataController* app_data_controller;
@property(nonatomic, retain) UITableView* table_view;
@end

@implementation ReleasesSearchHistoryTableViewCell

+(NSString*)getIdentifier {
    return @"ReleasesSearchHistoryTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _magnifier_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]];
    _history_item_label = [UILabel new];
    _history_item_label.numberOfLines = 1;
    _history_item_label.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:_magnifier_image_view];
    [self addSubview:_history_item_label];
    
    _magnifier_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _history_item_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_magnifier_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_magnifier_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_magnifier_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_magnifier_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],

        [_history_item_label.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_history_item_label.leadingAnchor constraintEqualToAnchor:_magnifier_image_view.trailingAnchor constant:5],
        [_history_item_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_history_item_label.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
    ]];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _magnifier_image_view.tintColor = [AppColorProvider textSecondaryColor];
    _history_item_label.textColor = [AppColorProvider textColor];
}

-(void)setHistoryText:(NSString*)text {
    _history_item_label.text = text;
}
-(NSString*)getHistoryText {
    return _history_item_label.text;
}

@end


@implementation ReleasesSearchHistoryTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _app_data_controller = [AppDataController sharedInstance];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _table_view = [UITableView new];
    _table_view.delegate = self;
    _table_view.dataSource = self;
    [_table_view registerClass:ReleasesSearchHistoryTableViewCell.class forCellReuseIdentifier:[ReleasesSearchHistoryTableViewCell getIdentifier]];
    
    [self.view addSubview:_table_view];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
    ]];
    if (@available(iOS 15.0, *)) {
        [_table_view.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor].active = YES;
    } else {
        [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    }
}

-(void)setupLayout {
    _table_view.backgroundColor = [AppColorProvider backgroundColor];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return [_app_data_controller getSearchHistoryLength];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    ReleasesSearchHistoryTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleasesSearchHistoryTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    [cell setHistoryText:[_app_data_controller getSearchHistoryItemAtIndex:index]];

    return cell;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)table_view trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = index_path.row;
    
    UIContextualAction* remove_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL action_performed)) {
        [self onRemoveTrailingActionAtIndex:index];
        completion_handler(YES);
    }];
    remove_action.backgroundColor = [UIColor systemRedColor];
    remove_action.image = [UIImage systemImageNamed:@"trash"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[
        remove_action
    ]];
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    ReleasesSearchHistoryTableViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    
    [_app_data_controller addSearchHistoryItem:[cell getHistoryText]];
    [_delegate releasesSearchHistoryTableViewController:self didSelectHistoryItem:[cell getHistoryText]];
}

-(void)onRemoveTrailingActionAtIndex:(NSInteger)index {
    [_app_data_controller removeSearchHistoryItemAtIndex:index];
    
    NSIndexSet* sections = [NSIndexSet indexSetWithIndex:0];
    [_table_view reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
