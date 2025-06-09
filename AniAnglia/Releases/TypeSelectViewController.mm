//
//  TypeSelectViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 30.09.2024.
//

#import "TypeSelectViewController.h"
#import "LibanixartApi.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "SourceSelectViewController.h"
#import "LoadableView.h"

@interface TypeViewCell : UITableViewCell
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UILabel* ep_count_label;
@property(nonatomic, retain) UILabel* view_count_label;
@property(nonatomic, retain) UIImageView* view_image_view;

+(NSString*)getIndentifier;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;

-(void)setName:(NSString*)name;
-(void)setEpCount:(NSString*)ep_count;
-(void)setViewCount:(NSString*)view_count;

@end

@interface TypeSelectViewController () {
    anixart::ReleaseID _release_id;
    std::vector<anixart::EpisodeType::Ptr> _types;
}
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) LoadableView* loadable_view;
@end


@implementation TypeViewCell

+(NSString*)getIndentifier {
    return @"TypeViewCell";
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _name_label = [UILabel new];
    _ep_count_label = [UILabel new];
    _view_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"eye"]];
    
    _view_count_label = [UILabel new];
    _view_count_label.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_name_label];
    [self.contentView addSubview:_ep_count_label];
    [self.contentView addSubview:_view_image_view];
    [self.contentView addSubview:_view_count_label];
    
    _name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    _view_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _view_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_name_label.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [_name_label.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [_name_label.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_name_label.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.35],
        [_name_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_ep_count_label.topAnchor constraintEqualToAnchor:_name_label.topAnchor],
        [_ep_count_label.leadingAnchor constraintEqualToAnchor:_name_label.trailingAnchor constant:5],
        [_ep_count_label.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_ep_count_label.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.2],
        [_ep_count_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_view_count_label.topAnchor constraintGreaterThanOrEqualToAnchor:_ep_count_label.topAnchor],
        [_view_count_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_ep_count_label.trailingAnchor constant:5],
        [_view_count_label.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_view_count_label.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.2],
        [_view_count_label.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
        
        [_view_image_view.leadingAnchor constraintEqualToAnchor:_view_count_label.trailingAnchor constant:5],
        [_view_image_view.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        [_view_image_view.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
        [_view_image_view.widthAnchor constraintEqualToConstant:28],
        [_view_image_view.heightAnchor constraintEqualToConstant:20]
    ]];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
    _ep_count_label.textColor = [AppColorProvider textSecondaryColor];
    _view_count_label.textColor = [AppColorProvider textSecondaryColor];
    _view_image_view.tintColor = [AppColorProvider textSecondaryColor];
}

-(void)setName:(NSString*)name {
    _name_label.text = name;
}
-(void)setEpCount:(NSString*)ep_count {
    _ep_count_label.text = ep_count;
}
-(void)setViewCount:(NSString*)view_count {
    _view_count_label.text = view_count;
}

@end

@implementation TypeSelectViewController

-(instancetype)initWithReleaseID:(anixart::ReleaseID)release_id {
    self = [super init];
    
    _release_id = release_id;
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self preSetup];
    [self preSetupLayout];
    [self loadTypes];
}

-(void)preSetup {
    self.navigationItem.title = NSLocalizedString(@"app.type_select.nav_item.title", "");
    
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
    [_table_view registerClass:TypeViewCell.class forCellReuseIdentifier:[TypeViewCell getIndentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    
    [self.view addSubview:_table_view];
    
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_table_view.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor],
        [_table_view.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor],
        [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_table_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _table_view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)loadTypes {
    [_loadable_view startLoading];
    
    [_api_proxy asyncCall:^BOOL(anixart::Api* api) {
        self->_types = api->episodes().get_release_types(self->_release_id);
        return NO;
    } completion:^(BOOL errored) {
        [self->_loadable_view endLoadingWithErrored:errored];
        if (!errored) {
            [self setup];
        }
    }];
}

-(NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return _types.size();
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    TypeViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TypeViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    anixart::EpisodeType::Ptr& type = _types[index];
    
    [cell setName:TO_NSSTRING(type->name)];
    [cell setEpCount:[NSString stringWithFormat:@"%lld %@", type->episodes_count, NSLocalizedString(@"app.type_select.cell.ep_count.name", "")]];
    [cell setViewCount:[AbbreviateNumberFormatter stringFromNumber: type->view_count]];

    return cell;
}

-(void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger index = [index_path item];
    anixart::EpisodeType::Ptr& type = _types[index];
    
    [self.navigationController pushViewController:[[SourceSelectViewController alloc] initWithReleaseID:_release_id typeID:type->id typeName:TO_NSSTRING(type->name)] animated:YES];
}

@end
