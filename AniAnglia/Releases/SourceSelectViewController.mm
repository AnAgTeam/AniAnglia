//
//  SourceSelectViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import "SourceSelectViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "EpisodeSelectViewController.h"
#import "LoadableView.h"

@interface SourceViewCell : UITableViewCell
@property(nonatomic, retain) UILabel* name_label;

+(NSString*)getIndentifier;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;

-(void)setName:(NSString*)name;
@end

@interface SourceSelectViewController () {
    anixart::ReleaseID _release_id;
    anixart::EpisodeTypeID _type_id;
    std::vector<anixart::EpisodeSource::Ptr> _sources;
}
@property(nonatomic, retain) NSString* type_name;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) UIView* header_view;
@property(nonatomic, retain) UILabel* type_name_label;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@end

@implementation SourceViewCell

+(NSString*)getIndentifier {
    return @"SourceViewCell";
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _name_label = [UILabel new];
    
    [self.contentView addSubview:_name_label];
    
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_name_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_name_label.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor],
        [_name_label.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
}

-(void)setName:(NSString*)name {
    _name_label.text = name;
}

@end

@implementation SourceSelectViewController

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id typeID:(anixart::EpisodeTypeID)type_id typeName:(NSString*)type_name {
    self = [super init];
    
    _release_id = release_id;
    _type_id = type_id;
    _type_name = type_name;
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    [self loadSources];
}

-(void)preSetup {
    self.navigationItem.title = NSLocalizedString(@"app.source_select.nav_item.title", "");
    
    _loadable_view = [LoadableView new];
    
    [self.view addSubview:_loadable_view];
    
    _loadable_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_loadable_view.centerYAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerYAnchor],
        [_loadable_view.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor]
    ]];
}

-(void)setup {
    _table_view = [UITableView new];
    [_table_view registerClass:SourceViewCell.class forCellReuseIdentifier:[SourceViewCell getIndentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    
    _type_name_label = [UILabel new];
    _type_name_label.text = _type_name;
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

-(void)loadSources {
    [_loadable_view startLoading];
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_sources = api->episodes().get_release_sources(self->_release_id, self->_type_id);
        return NO;
    } completion:^(BOOL errored) {
        [self->_loadable_view endLoadingWithErrored:errored];
        if (!errored) {
            [self setup];
        }
    }];
}


-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return _sources.size();
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    SourceViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[SourceViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::EpisodeSource::Ptr& source = _sources[index];
    
    [cell setName:TO_NSSTRING(source->name)];

    return cell;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::EpisodeSource::Ptr& source = _sources[index];
    
    [self.navigationController pushViewController:[[EpisodeSelectViewController alloc] initWithReleaseID:_release_id typeID:_type_id typeName:_type_name sourceID:source->id sourceName:TO_NSSTRING(source->name)] animated:NO];
}

@end
