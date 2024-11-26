//
//  SearchReleasesViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <Foundation/Foundation.h>
#import "SearchReleasesView.h"
#import "AppColor.h"
#import "LoadableView.h"
#import "StringCvt.h"
#import "ReleaseViewController.h"

@interface SearchReleaseTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* description_label;
@property(nonatomic, retain) UILabel* ep_count_label;
@property(nonatomic, retain) UILabel* rating_label;

+(NSString*)getIndentifier;
@end

@interface SearchReleasesView ()
@property(atomic) BOOL dont_fetch_pages;
@property(atomic) NSUInteger current_page;
@property(nonatomic, retain) UITableView* table_view;
@end

@implementation SearchReleaseTableViewCell

static const CGFloat RATING_BADGE_HEIGHT = 35;
static const CGFloat TOP_BOTTOM_CELL_OFFSET = 7;

+(NSString*)getIndentifier {
    return @"SearchReleaseTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    
    return self;
}

-(void)setup {
    _image_view = [LoadableImageView new];
    [self addSubview:_image_view];
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_image_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:9].active = YES;
    [_image_view.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.93 constant:-TOP_BOTTOM_CELL_OFFSET * 2].active = YES;
    [_image_view.widthAnchor constraintEqualToAnchor:_image_view.heightAnchor multiplier:0.56].active = YES;
    _image_view.layer.cornerRadius = 6.0;
    _image_view.clipsToBounds = YES;

    _title_label = [UILabel new];
    [self addSubview:_title_label];
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_title_label.topAnchor constraintEqualToAnchor:_image_view.topAnchor].active = YES;
    [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5].active = YES;
    [_title_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
//    [_title_label.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.25].active = YES;
    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 2;
    _title_label.font = [_title_label.font fontWithSize:23];
    [_title_label sizeToFit];
    
    _ep_count_label = [UILabel new];
    [self addSubview:_ep_count_label];
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_ep_count_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor].active = YES;
    [_ep_count_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor].active = YES;
    [_ep_count_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    _description_label = [UILabel new];
    [self addSubview:_description_label];
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_description_label.topAnchor constraintEqualToAnchor:_ep_count_label.bottomAnchor].active = YES;
    [_description_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor].active = YES;
    [_description_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor].active = YES;
    [_description_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    _description_label.textAlignment = NSTextAlignmentJustified;
    _description_label.numberOfLines = -1;
    
    _rating_label = [UILabel new];
    [self addSubview:_rating_label];
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_rating_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor].active = YES;
    [_rating_label.trailingAnchor constraintEqualToAnchor:_image_view.trailingAnchor].active = YES;
    [_rating_label.heightAnchor constraintEqualToConstant:RATING_BADGE_HEIGHT].active = YES;
    [_rating_label.widthAnchor constraintEqualToAnchor:_rating_label.heightAnchor].active = YES;
    _rating_label.layer.cornerRadius = RATING_BADGE_HEIGHT / 2;
    _rating_label.layer.masksToBounds = YES;
    _rating_label.textAlignment = NSTextAlignmentCenter;
    
    [self setupLayout];
}

-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _description_label.textColor = [AppColorProvider textSecondaryColor];
    _ep_count_label.textColor = [AppColorProvider textColor];
    _rating_label.textColor = [AppColorProvider textColor];
    _rating_label.backgroundColor = [UIColor systemGrayColor];
}

-(void)setEpCount:(NSUInteger)ep_count {
    _ep_count_label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"app.release_search.ep_count.text", ""), [@(ep_count) stringValue]];
    [_ep_count_label sizeToFit];
    [_ep_count_label layoutIfNeeded];
}

-(void)setRating:(double)rating {
    rating = round(rating * 10) / 10;
    _rating_label.text = [@(rating) stringValue];
    if (rating >= 4) {
        _rating_label.backgroundColor = [UIColor systemGreenColor];
    }
    else if (rating >= 3) {
        _rating_label.backgroundColor = [UIColor systemOrangeColor];
    }
    else if (rating > 0) {
        _rating_label.backgroundColor = [UIColor systemRedColor];
    }
    else {
        _rating_label.backgroundColor = [UIColor systemGrayColor];
    }
}

@end

@implementation SearchReleasesView

static const CGFloat TABLE_CELL_HEIGHT = 175;

-(instancetype)init {
    self = [super init];
    
    [self setup];
    
    return self;
}

-(void)setDataSource:(id<SearchReleasesViewDataSource>)data_source {
    _data_source = data_source;
}

-(void)setup {
    _table_view = [UITableView new];
    [self addSubview:_table_view];
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_table_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_table_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_table_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_table_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [_table_view setDelegate:self];
    [_table_view registerClass:SearchReleaseTableViewCell.class forCellReuseIdentifier:[SearchReleaseTableViewCell getIndentifier]];
    [_table_view setDataSource:self];
    [_table_view setPrefetchDataSource:self];
}

-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
    _table_view.backgroundColor = [UIColor clearColor];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return [_data_source numberOfItemsForSearchReleasesView:self];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_CELL_HEIGHT;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    SearchReleaseTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[SearchReleaseTableViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    libanixart::Release::Ptr release = [_data_source searchReleasesView:self releaseAtIndex:index];
    
    cell.title_label.text = TO_NSSTRING(release->title_ru);
    cell.description_label.text = TO_NSSTRING(release->description);
    [cell setEpCount:release->episodes_released];
    [cell setRating:release->grade];
    [cell.image_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(release->image_url)]];
    
    return cell;
}

-(void)tableView:(UITableView *)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    NSUInteger item_count = [_table_view numberOfRowsInSection:0];
    NSArray* filtered = [index_paths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id index_path, NSDictionary *bindings) {
        return [index_path row] >= item_count - 1;
    }]];
    if ([filtered count] > 0) {
        if (_data_source) {
            [_data_source searchReleasesView:self loadNextPageWithcompletionHandler:^(BOOL action_performed) {
                self->_dont_fetch_pages |= !action_performed;
                if (action_performed) {
                    [self->_table_view reloadData];
                }
            }];
        }
    }
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    [_delegate searchReleasesView:self didSelectReleaseAtIndex:index];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)table_view trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)index_path {
    
    UIContextualAction* bookmark_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL action_performed)) {
        [self addCellToBookmarkAtIndexPath:index_path];
        completion_handler(YES);
    }];
    bookmark_action.backgroundColor = [UIColor systemYellowColor];
    bookmark_action.image = [UIImage systemImageNamed:@"bookmark"];
    UIContextualAction* add_to_list_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL action_performed)){
        [self addCellToListAtIndexPath:index_path];
        completion_handler(YES);
    }];
    add_to_list_action.image = [UIImage systemImageNamed:@"line.3.horizontal"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[
        bookmark_action,
        add_to_list_action
    ]];
}

-(void)searchViewDidShowWithController:(NavigationSearchViewController *)view_controller {
    _dont_fetch_pages = NO;
    if (_data_source) {
        [_data_source searchReleasesView:self loadPage:0 completionHandler:^(BOOL action_performed){
            self->_dont_fetch_pages |= !action_performed;
            if (action_performed) {
                [self->_table_view reloadData];
            }
        }];
    }
    [_table_view reloadData];
}

-(void)addCellToBookmarkAtIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToBookmarkAtIndexPath:%@", index_path);
}
-(void)addCellToListAtIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToListAtIndexPath:%@", index_path);
}
-(void)addCellToList:(libanixart::ReleaseListStatus)list atIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToList:%d atIndexPath:%@", list, index_path);
}

@end
