//
//  HistoryTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesHistoryTableViewController.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface ReleasesHistoryTableViewCell : UITableViewCell
@property(nonatomic, retain) UIImageView* magnifier_image_view;
@property(nonatomic, retain) UILabel* history_item_label;

+(NSString*)getIdentifier;
-(void)setHistoryText:(NSString*)text;
-(NSString*)getHistoryText;
@end

@interface ReleasesHistoryTableViewController ()
@property(nonatomic) AppDataController* app_data_controller;
@property(nonatomic, retain) UITableView* table_view;
@end

@implementation ReleasesHistoryTableViewCell

+(NSString*)getIdentifier {
    return @"HistoryTableViewCell";
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


@implementation ReleasesHistoryTableViewController

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
    [_table_view registerClass:ReleasesHistoryTableViewCell.class forCellReuseIdentifier:[ReleasesHistoryTableViewCell getIdentifier]];
    
    [self.view addSubview:_table_view];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
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
    ReleasesHistoryTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleasesHistoryTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    [cell setHistoryText:[_app_data_controller getSearchHistoryItemAtIndex:index]];

    return cell;
}
-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    ReleasesHistoryTableViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    
    [_app_data_controller addSearchHistoryItem:[cell getHistoryText]];
    [_delegate releasesHistoryTableViewController:self didSelectHistoryItem:[cell getHistoryText]];
}

@end
