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

@interface TypeViewCell : UITableViewCell
@property(nonatomic, retain) UILabel* name_label;
@property(nonatomic, retain) UILabel* ep_count_label;
@property(nonatomic, retain) UILabel* view_count_label;
@property(nonatomic, retain) UIImageView* view_image_view;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier;
+(NSString*)getIndentifier;
-(void)setupDarkLayout;
@end

@interface TypeSelectViewController ()
@property(atomic) long long release_id;
@property(nonatomic) std::vector<libanixart::EpisodeType::Ptr> types_arr;
@property(nonatomic, retain) LibanixartApi* api_proxy;
@property(nonatomic, retain) UITableView* table_view;
@property(nonatomic, retain) UIActivityIndicatorView* loading_ind;
@end


@implementation TypeViewCell

+(NSString*)getIndentifier {
    return @"TypeViewCell";
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
    
    _ep_count_label = [UILabel new];
    [self addSubview:_ep_count_label];
    _ep_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_ep_count_label.leadingAnchor constraintEqualToAnchor:_name_label.trailingAnchor constant:5].active = YES;
    [_ep_count_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_ep_count_label.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.2].active = YES;
    [_ep_count_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    
    _view_image_view = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"eye"]];
    [self addSubview:_view_image_view];
    _view_image_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_view_image_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;
    [_view_image_view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_view_image_view.widthAnchor constraintEqualToConstant:28].active = YES;
    [_view_image_view.heightAnchor constraintEqualToConstant:20].active = YES;
    
    _view_count_label = [UILabel new];
    [self addSubview:_view_count_label];
    _view_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    [_view_count_label.trailingAnchor constraintEqualToAnchor:_view_image_view.leadingAnchor constant:-5].active = YES;
    [_view_count_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_view_count_label.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.2].active = YES;
    [_view_count_label.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
    _view_count_label.textAlignment = NSTextAlignmentRight;
    
    [self setupLayout];
}
-(void)setupLayout {
    self.backgroundColor = [AppColorProvider backgroundColor];
    _name_label.textColor = [AppColorProvider textColor];
    _ep_count_label.textColor = [AppColorProvider textSecondaryColor];
    _view_count_label.textColor = [AppColorProvider textSecondaryColor];
    _view_image_view.tintColor = [AppColorProvider textSecondaryColor];
}

@end

@implementation TypeSelectViewController

-(instancetype)initWithReleaseID:(long long)release_id {
    self = [super init];
    
    self.release_id = release_id;
    self.api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)loadTypes {
    [_loading_ind startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            self->_types_arr = self->_api_proxy.api->get_episodes().get_release_types(self->_release_id);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_loading_ind stopAnimating];
                [self setupTypesView];
            });
        } catch (libanixart::ApiError& e) {
            // error
        }
    });
}

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
//    return 1;
//}
- (NSInteger)tableView:(UITableView *)table_view numberOfRowsInSection:(NSInteger)section {
    return _types_arr.size();
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path {
    TypeViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[TypeViewCell getIndentifier] forIndexPath:index_path];
    NSInteger index = [index_path item];
    cell.name_label.text = TO_NSSTRING(_types_arr[index]->name);
    cell.ep_count_label.text = [NSString stringWithFormat:@"%lld %@", _types_arr[index]->episodes_count, NSLocalizedString(@"app.type_select.cell.ep_count.name", "")];
    cell.view_count_label.text = [AbbreviateNumberFormatter stringFromNumber: _types_arr[index]->view_count];
    [cell.name_label sizeToFit];

    return cell;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    self.navigationItem.title = NSLocalizedString(@"app.type_select.nav_item.title", "");
    
    _loading_ind = [UIActivityIndicatorView new];
    [self.view addSubview:_loading_ind];
    _loading_ind.transform = CGAffineTransformMakeScale(3.5, 3.5);
    _loading_ind.translatesAutoresizingMaskIntoConstraints = NO;
    [_loading_ind.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_loading_ind.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_loading_ind.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.bottomAnchor multiplier:0.5].active = YES;
    [_loading_ind.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    [self preSetupLayout];
    
    [self loadTypes];
}

-(void)setupTypesView {
    
    _table_view = [UITableView new];
    [self.view addSubview:_table_view];
    _table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_table_view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_table_view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_table_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [_table_view setDelegate:self];
    [_table_view setDataSource:self];
    [_table_view registerClass:TypeViewCell.class forCellReuseIdentifier:[TypeViewCell getIndentifier]];
    
    [self setupLayout];
}

-(void)preSetupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setupLayout {
    _table_view.backgroundColor = [AppColorProvider backgroundColor];
}

- (void)tableView:(UITableView *)table_view didSelectRowAtIndexPath:(NSIndexPath *)index_path {
    NSLog(@"TableView: didSelectRowAtIndexPath:%@", index_path);
    NSInteger index = [index_path item];
    libanixart::EpisodeType::Ptr& type = _types_arr[index];
    SourceSelectViewController* vc = [[SourceSelectViewController alloc] initWithReleaseID:_release_id typeID:type->id typeName:TO_NSSTRING(type->name)];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
