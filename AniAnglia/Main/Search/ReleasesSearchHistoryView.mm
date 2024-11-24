//
//  ReleasesSearchHistoryView.m
//  AniAnglia
//
//  Created by Toilettrauma on 24.11.2024.
//

#import <Foundation/Foundation.h>
#import "ReleasesSearchHistoryView.h"
#import "AppColor.h"
#import "AppDataController.h"

@interface HistoryTableViewCell : UITableViewCell
@property(nonatomic, retain) UIImageView* magnifier_image_view;
@property(nonatomic, retain) UILabel* history_item_label;

+(NSString*)getIndentifier;
@end

@interface ReleasesSearchHistoryView ()
@property(nonatomic, weak) NavigationSearchViewController* base_view_controller;
@property(nonatomic) AppDataController* app_data;
@property(nonatomic, retain) UITableView* table_view;
@end

@implementation HistoryTableViewCell

+(NSString*)getIndentifier {
    return @"HistoryTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setupView];
    
    return self;
}

-(void)setupView {
    
    _magnifier_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]];
    [self addSubview:_magnifier_image_view];
    _magnifier_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_magnifier_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5.0].active = YES;
    [_magnifier_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_magnifier_image_view.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.55].active = YES;
    [_magnifier_image_view.widthAnchor constraintEqualToAnchor:_magnifier_image_view.heightAnchor].active = YES;

    _history_item_label = [UILabel new];
    [self addSubview:_history_item_label];
    _history_item_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_history_item_label.leadingAnchor constraintEqualToAnchor:_magnifier_image_view.trailingAnchor constant:5].active = YES;
    [_history_item_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_history_item_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
    [_history_item_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    _history_item_label.textAlignment = NSTextAlignmentLeft;
    
    [self setupLayout];
}

-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _magnifier_image_view.tintColor = [AppColorProvider textColor];
    _history_item_label.textColor = [AppColorProvider textColor];
}

@end


@implementation ReleasesSearchHistoryView

-(instancetype)init {
    self = [super init];
    
    _app_data = [AppDataController sharedInstance];
    [self setupView];
    
    return self;
}

-(void)setupView {
    _table_view = [UITableView new];
    [self addSubview:_table_view];
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_table_view registerClass:HistoryTableViewCell.class forCellReuseIdentifier:[HistoryTableViewCell getIndentifier]];
    [_table_view setDelegate:self];
    [_table_view setDataSource:self];
    
    [_table_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_table_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_table_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_table_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [self setupLayout];
}

-(void)setupLayout {
    
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return [_app_data getSearchHistoryLength];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    HistoryTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[HistoryTableViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    cell.history_item_label.text = [_app_data getSearchHistoryItemAtIndex:index];

    return cell;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    HistoryTableViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    
    [_base_view_controller setSearchText:cell.history_item_label.text endEditingAsFinal:YES];
}

-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller {
    _base_view_controller = view_controller;
    [_table_view reloadData];
}
-(void)searchTextDidChanged:(NSString*)text {
    NSLog(@"searchTextDidChanged:%@", text);
}
-(void)searchViewDidCancelWithText:(NSString*)text isSearchQuery:(BOOL)is_search_query {
    if (is_search_query) {
        [_app_data addSearchHistoryItem:text];
    }
}

@end

