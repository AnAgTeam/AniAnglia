//
//  EpisodeSelectViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import "EpisodeSelectViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "PlayerViewController.h"
#import "LoadableView.h"

@interface EpisodeViewCell : UITableViewCell
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIImageView* watched_image_view;

+(NSString*)getIndentifier;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;

-(void)setName:(NSString*)name;
-(void)setWatchedStatus:(BOOL)is_wached;
@end

@interface EpisodeSelectViewController () {
    anixart::ReleaseID _release_id;
    anixart::EpisodeTypeID _type_id;
    anixart::EpisodeSourceID _source_id;
    std::vector<anixart::Episode::Ptr> _episodes;
}
@property(nonatomic, retain) NSString* type_name;
@property(nonatomic, retain) NSString* source_name;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIView* header_view;
@property(nonatomic, retain) UILabel* type_name_label;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;

@property(nonatomic, retain) PlayerController* player_controller;
@end

@implementation EpisodeViewCell

+(NSString*)getIndentifier {
    return @"EpisodeViewCell";
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _name_label = [UILabel new];
    
    _watched_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"eye"]];
    _watched_image_view.hidden = YES;
    
    [self.contentView addSubview:_name_label];
    [self.contentView addSubview:_watched_image_view];
    
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _watched_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_name_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_name_label.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_name_label.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.35],
        [_name_label.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor],
        
        [_watched_image_view.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_watched_image_view.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_watched_image_view.widthAnchor constraintEqualToConstant:28],
        [_watched_image_view.heightAnchor constraintEqualToConstant:20]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
    _watched_image_view.tintColor = [AppColorProvider textSecondaryColor];
}

-(void)setName:(NSString*)name {
    _name_label.text = name;
}

-(void)setWatchedStatus:(BOOL)is_wached {
    _watched_image_view.hidden = !is_wached;
}

@end

@implementation EpisodeSelectViewController

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id typeID:(anixart::EpisodeTypeID)type_id typeName:(NSString*)type_name sourceID:(anixart::EpisodeSourceID)source_id sourceName:(NSString*) source_name {
    self = [super init];
    
    _release_id = release_id;
    _type_id = type_id;
    _type_name = type_name;
    _source_id = source_id;
    _source_name = source_name;
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    [self loadEpisodes];
}

-(void)preSetup {
    self.navigationItem.title = NSLocalizedString(@"app.episode_select.nav_item.title", "");
    
    _loadable_view = [LoadableView new];
    
    [self.view addSubview:_loadable_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor]
    ]];
}

-(void)setup {
    _table_view = [UITableView new];
    [_table_view registerClass:EpisodeViewCell.class forCellReuseIdentifier:[EpisodeViewCell getIndentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    
    _type_name_label = [UILabel new];
    _type_name_label.text = [NSString stringWithFormat:@"%@ (%@)", _type_name, _source_name];
    _type_name_label.font = [UIFont boldSystemFontOfSize:25];
    
    _header_view = [UIView new];
    
    [self.view addSubview:_table_view];
    [_header_view addSubview:_type_name_label];
    _table_view.tableHeaderView = _header_view;
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    _header_view.translatesAutoresizingMaskIntoConstraints = NO;
    _type_name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_header_view.topAnchor constraintEqualToAnchor:_table_view.topAnchor],
        [_header_view.leadingAnchor constraintEqualToAnchor:_table_view.layoutMarginsGuide.leadingAnchor],
        [_header_view.trailingAnchor constraintEqualToAnchor:_table_view.layoutMarginsGuide.trailingAnchor],
        [_header_view.heightAnchor constraintEqualToAnchor:_type_name_label.heightAnchor constant:5],
        
        [_type_name_label.leadingAnchor constraintEqualToAnchor:_header_view.leadingAnchor],
        [_type_name_label.trailingAnchor constraintEqualToAnchor:_header_view.trailingAnchor],
        
        [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_table_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_table_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    [_header_view setNeedsLayout];
    [_header_view layoutIfNeeded];
    _table_view.tableHeaderView = _header_view;
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _table_view.backgroundColor = [AppColorProvider backgroundColor];
    _type_name_label.textColor = [AppColorProvider textColor];
}

-(void)loadEpisodes {
    [_loadable_view startLoading];
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_episodes = api->episodes().get_release_episodes(self->_release_id, self->_type_id, self->_source_id, anixart::Episode::Sort::FromLeast);
        return NO;
    } completion:^(BOOL errored) {
        [self->_loadable_view endLoadingWithErrored:errored];
        if (!errored) {
            [self setup];
        }
    }];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return _episodes.size();
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    EpisodeViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[EpisodeViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Episode::Ptr episode = _episodes[index];
    
    [cell setName:TO_NSSTRING(episode->name)];
    [cell setWatchedStatus:episode->is_watched];

    return cell;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)table_view trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    
    UIContextualAction* download_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL actionPerformed)) {
        [self cellDownloadButtonActionPressed:index_path];
        completion_handler(true);
    }];
    download_action.backgroundColor = [UIColor colorWithRed:0.37 green:0.62 blue:0.63 alpha:1.0];
    download_action.image = [UIImage systemImageNamed:@"arrow.down.to.line"];
    UIContextualAction* change_viewed_action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction *action, UIView *source_view, void (^completion_handler)(BOOL actionPerformed)) {
        [self cellChangeViewedActionPressed:index_path];
        completion_handler(true);
    }];
    if (!_episodes[index]->is_watched) {
        change_viewed_action.image = [UIImage systemImageNamed:@"eye"];
    } else {
        change_viewed_action.image = [UIImage systemImageNamed:@"eye.slash"];
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:@[
        download_action,
        change_viewed_action
    ]];
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSInteger index = [index_path item];
    EpisodeViewCell* cell = [table_view cellForRowAtIndexPath:index_path];
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    
    anixart::Episode::Ptr episode = _episodes[index];
    [[PlayerController sharedInstance] playWithReleaseID:_release_id sourceID:_source_id position:episode->position autoShow:YES completion:^(BOOL errored){
        if (errored) {
            return;
        }
        /* pre set just for instant UI update. Then update to real state */
        episode->is_watched = YES;
        [cell setWatchedStatus:YES];
        
        [self->_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
            api->episodes().add_watched_episode(self->_release_id, self->_source_id, episode->position);
            return YES;
        } withUICompletion:^{
            episode->is_watched = YES;
            [cell setWatchedStatus:YES];
        }];
    }];
}

-(void)cellDownloadButtonActionPressed:(NSIndexPath*)index_path {
    NSLog(@"cellDownloadButtonActionPressed:%@", index_path);
}
-(void)cellChangeViewedActionPressed:(NSIndexPath*)index_path {
    NSInteger index = [index_path item];
    EpisodeViewCell* cell = [_table_view cellForRowAtIndexPath:index_path];
    anixart::Episode::Ptr episode = _episodes[index];
    
    BOOL to_set_watched = !_episodes[index]->is_watched;
    /* pre set just for instant UI update. Then update to real state */
    episode->is_watched = to_set_watched;
    [cell setWatchedStatus:to_set_watched];
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (to_set_watched) {
            api->episodes().add_watched_episode(self->_release_id, self->_source_id, episode->position);
        } else {
            api->episodes().remove_watched_episode(self->_release_id, self->_source_id, episode->position);
        }
        return YES;
    } withUICompletion:^{
        episode->is_watched = to_set_watched;
        [cell setWatchedStatus:to_set_watched];
    }];
}

@end
