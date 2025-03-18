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

@interface EpisodeViewCell : UITableViewCell
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UIImageView* watched_image_view;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;
+(NSString*)getIndentifier;
-(void)setupDarkLayout;

-(void)setWatchedStatus:(BOOL)is_wached;
@end

@interface EpisodeSelectViewController ()
@property(atomic) anixart::ReleaseID release_id;
@property(atomic) anixart::EpisodeTypeID type_id;
@property(nonatomic, retain) NSString* type_name;
@property(atomic) anixart::EpisodeSourceID source_id;
@property(nonatomic, retain) NSString* source_name;
@property(nonatomic) std::vector<anixart::Episode::Ptr> episodes_arr;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) UILabel* type_name_label;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) UIActivityIndicatorView* loading_ind;

@property(nonatomic, retain) PlayerController* player_controller;
@end

@implementation EpisodeViewCell

+(NSString*)getIndentifier {
    return @"EpisodeViewCell";
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setupView];
    
    return self;
}
-(void)setupView {
    _name_label = [UILabel new];
    [self addSubview:_name_label];
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_name_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;
    [_name_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_name_label.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.35].active = YES;
    [_name_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    
    _watched_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"eye"]];
    [self addSubview:_watched_image_view];
    _watched_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_watched_image_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
    [_watched_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_watched_image_view.widthAnchor constraintEqualToConstant:28].active = YES;
    [_watched_image_view.heightAnchor constraintEqualToConstant:20].active = YES;
    _watched_image_view.hidden = YES;
    
    [self setupDarkLayout];
}
-(void)setupDarkLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
    _watched_image_view.tintColor = [AppColorProvider textSecondaryColor];
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

-(void)loadEpisodes {
    [_loading_ind startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            self->_episodes_arr = self->_api_proxy.api->episodes().get_release_episodes(self->_release_id, self->_type_id, self->_source_id, anixart::Episode::Sort::FromLeast);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_loading_ind stopAnimating];
                [self setupEpisodesView];
            });
        } catch (anixart::ApiError& e) {
            // error
        }
    });
}

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
//    return 1;
//}
-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return _episodes_arr.size();
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    EpisodeViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[EpisodeViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::Episode::Ptr episode = _episodes_arr[index];
    cell.name_label.text = TO_NSSTRING(episode->name);
    [cell setWatchedStatus:episode->is_watched];

    return cell;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    self.navigationItem.title = NSLocalizedString(@"app.episode_select.nav_item.title", "");
    
    _loading_ind = [UIActivityIndicatorView new];
    [self.view addSubview:_loading_ind];
    _loading_ind.transform = CGAffineTransformMakeScale(3.5, 3.5);
    _loading_ind.translatesAutoresizingMaskIntoConstraints = NO;
    [_loading_ind.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_loading_ind.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_loading_ind.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.bottomAnchor multiplier:0.5].active = YES;
    [_loading_ind.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    [self preSetupLayout];
    
    [self loadEpisodes];
}

-(void)setupEpisodesView {
    
    _table_view = [UITableView new];
    [self.view addSubview:_table_view];
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_table_view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_table_view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [_table_view setDelegate:self];
    [_table_view setDataSource:self];
    [_table_view registerClass:EpisodeViewCell.class forCellReuseIdentifier:[EpisodeViewCell getIndentifier]];
    
    [self addTableTypeHeader];
    
    [self setupLayout];
}

-(void)addTableTypeHeader {
    _type_name_label = [UILabel new];
    _type_name_label.text = _type_name;
    _type_name_label.font = [UIFont boldSystemFontOfSize:25];
    UIView *header_view = [UIView new];
    [header_view addSubview:_type_name_label];
    [_type_name_label sizeToFit];
    
    _table_view.tableHeaderView = header_view;
    [header_view setNeedsLayout];
    [header_view layoutIfNeeded];
    header_view.frame = CGRectMake(0, 0, _table_view.frame.size.width, 40);
    
    header_view.translatesAutoresizingMaskIntoConstraints = NO;
    [header_view.widthAnchor constraintEqualToAnchor:_table_view.widthAnchor].active = YES;
    [header_view.leadingAnchor constraintEqualToAnchor:_table_view.leadingAnchor].active = YES;
    _type_name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_type_name_label.leadingAnchor constraintEqualToAnchor:header_view.leadingAnchor constant:5].active = YES;
    [header_view.heightAnchor constraintEqualToAnchor:_type_name_label.heightAnchor].active = YES;
    _table_view.tableHeaderView = header_view;
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _table_view.backgroundColor = [AppColorProvider backgroundColor];
    _type_name_label.textColor = [AppColorProvider textColor];
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
    if (!_episodes_arr[index]->is_watched) {
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
    
    anixart::Episode::Ptr episode = _episodes_arr[index];
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
    anixart::Episode::Ptr episode = _episodes_arr[index];
    
    BOOL to_set_watched = !_episodes_arr[index]->is_watched;
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
