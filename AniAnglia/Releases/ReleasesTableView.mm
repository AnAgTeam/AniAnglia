//
//  ReleaseTableView.m
//  AniAnglia
//
//  Created by Toilettrauma on 09.12.2024.
//

#import <Foundation/Foundation.h>
#import "ReleasesTableView.h"
#import "AppColor.h"
#import "LoadableView.h"
#import "StringCvt.h"
#import "ReleaseViewController.h"

@interface ReleasesTableViewCell : UITableViewCell
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* description_label;
@property(nonatomic, retain) UILabel* ep_count_label;
@property(nonatomic, retain) UILabel* rating_label;

+(NSString*)getIndentifier;

-(void)setRating:(double)rating;
-(void)setEpCount:(NSUInteger)ep_count;
@end

@interface ReleasesTableView () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    std::vector<anixart::Release::Ptr> _releases;
}
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) NSLock* lock;
@property(nonatomic, retain) LoadableView* loadable_view;
@property(nonatomic, retain) UILabel* empty_label;
@end

@implementation ReleasesTableViewCell

static const CGFloat RATING_BADGE_HEIGHT = 35;

+(NSString*)getIndentifier {
    return @"ReleasesTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    //    self.preservesSuperviewLayoutMargins = YES;
    _image_view = [LoadableImageView new];
    _image_view.layer.cornerRadius = 6.0;
    _image_view.clipsToBounds = YES;
    _image_view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 10, 0);
    
    _title_label = [UILabel new];
    _title_label.textAlignment = NSTextAlignmentJustified;
    _title_label.numberOfLines = 2;
    _title_label.font = [_title_label.font fontWithSize:23];
    
    _ep_count_label = [UILabel new];
    
    _description_label = [UILabel new];
    _description_label.textAlignment = NSTextAlignmentJustified;
    _description_label.numberOfLines = -1;
    
    _rating_label = [UILabel new];
    _rating_label.layer.cornerRadius = RATING_BADGE_HEIGHT / 2;
    _rating_label.layer.masksToBounds = YES;
    _rating_label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_ep_count_label];
    [self addSubview:_description_label];
    [self addSubview:_rating_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _description_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:0.93],
        [_image_view.widthAnchor constraintEqualToAnchor:_image_view.heightAnchor multiplier:(9. / 16)],
        
        [_title_label.topAnchor constraintEqualToAnchor:_image_view.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:8],
        [_title_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        //    [_title_label.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.25],
        
        [_ep_count_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_ep_count_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_ep_count_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_description_label.topAnchor constraintEqualToAnchor:_ep_count_label.bottomAnchor],
        [_description_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
        [_description_label.leadingAnchor constraintEqualToAnchor:_title_label.leadingAnchor],
        [_description_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_rating_label.bottomAnchor constraintEqualToAnchor:_image_view.bottomAnchor],
        [_rating_label.trailingAnchor constraintEqualToAnchor:_image_view.trailingAnchor],
        [_rating_label.heightAnchor constraintEqualToConstant:RATING_BADGE_HEIGHT],
        [_rating_label.widthAnchor constraintEqualToAnchor:_rating_label.heightAnchor],
    ]];
    [_title_label sizeToFit];
    [_ep_count_label sizeToFit];
    [_description_label sizeToFit];
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

@implementation ReleasesTableView

static const CGFloat TABLE_CELL_HEIGHT = 175;

-(instancetype)init {
    self = [super init];
    
    [self setup];
    _trailing_action_disabled = NO;
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    [self setup];
    _trailing_action_disabled = NO;
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    [self setPages:std::move(pages)];
    
    return self;
}

-(void)setup {
    [self registerClass:ReleasesTableViewCell.class forCellReuseIdentifier:[ReleasesTableViewCell getIndentifier]];
    [self setDelegate:self];
    [self setDataSource:self];
    [self setPrefetchDataSource:self];
    self.preservesSuperviewLayoutMargins = YES;
    
    _loadable_view = [LoadableView new];
    [self addSubview:_loadable_view];
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_loadable_view.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor].active = YES;
    [_loadable_view.centerYAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerYAnchor].active = YES;
    
    _empty_label = [UILabel new];
    [self addSubview:_empty_label];
    _empty_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_empty_label.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor].active = YES;
    [_empty_label.centerYAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerYAnchor].active = YES;
    _empty_label.text = NSLocalizedString(@"app.releases_table_view.is_empty_label.text", "");
    _empty_label.hidden = YES;
}

-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
    _loadable_view.backgroundColor = [UIColor clearColor];
    _empty_label.textColor = [AppColorProvider textColor];
}

-(UINavigationController*)getRootNavigationController {
    UIResponder* responder = self.nextResponder;
    while (true) {
        if ([responder isKindOfClass:UINavigationController.class]) {
            return (UINavigationController*)responder;
        } else if ([responder isKindOfClass:UIView.class] || [responder isKindOfClass:UIViewController.class]) {
            responder = responder.nextResponder;
        } else {
            return nil;
        }
    }
    return nil;
}

-(void)appendItemsFromBlock:(std::vector<anixart::Release::Ptr>(^)())block {
    [_loadable_view startLoading];
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        /* todo: change to thread-safe */
        auto new_items = block();
        [self->_lock lock];
        self->_releases.insert(self->_releases.end(), new_items.begin(), new_items.end());
        [self->_lock unlock];
        return YES;
    } withUICompletion:^{
        [self->_loadable_view endLoading];
        self->_empty_label.hidden = !self->_releases.empty();
        [self reloadData];
    }];
}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    _pages = std::move(pages);
    [self reset];
    [self appendItemsFromBlock:^{
        return self->_pages->get();
    }];
}
-(void)reset {
    /* todo: load cancel */
    _releases.clear();
    _empty_label.hidden = YES;
    [self reloadData];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return _releases.size();
}
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return TABLE_CELL_HEIGHT;
}
-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    ReleasesTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleasesTableViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _releases[index];
    
    cell.title_label.text = TO_NSSTRING(release->title_ru);
    cell.description_label.text = TO_NSSTRING(release->description);
    [cell setEpCount:release->episodes_released];
    [cell setRating:release->grade];
    [cell.image_view tryLoadImageWithURL:[NSURL URLWithString:TO_NSSTRING(release->image_url)]];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    if (_pages->is_end()) {
        return;
    }
    NSUInteger item_count = [self numberOfRowsInSection:0];
    for (NSIndexPath* index_path in index_paths) {
        if ([index_path row] >= item_count - 1) {
            [self appendItemsFromBlock:^{
                return self->_pages->next();
            }];
            return;
        }
    }
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::Release::Ptr& release = _releases[index];
    [[self getRootNavigationController] pushViewController:[[ReleaseViewController alloc] initWithReleaseID:release->id] animated:YES];
}

-(UISwipeActionsConfiguration*)tableView:(UITableView*)table_view trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath*)index_path {
    if (_trailing_action_disabled) {
        return nil;
    }
    
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

-(void)addCellToBookmarkAtIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToBookmarkAtIndexPath:%@", index_path);
}
-(void)addCellToListAtIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToListAtIndexPath:%@", index_path);
}
-(void)addCellToList:(anixart::Profile::ListStatus)status atIndexPath:(NSIndexPath*)index_path {
    NSLog(@"addCellToList:%d atIndexPath:%@", status, index_path);
}

@end


