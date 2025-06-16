//
//  ProfileFriendsViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfileFriendsViewController.h"
#import "LoadableView.h"
#import "AppColor.h"
#import "StringCvt.h"
#import "ProfileViewController.h"
#import "ProfileTableViewCell.h"

enum class ProfileFriendsSections {
    RequestsIn = 1,
    RequestsOut = 2,
    Friends = 3
};

@interface ProfileFriendsViewController () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching> {
    anixart::ProfileID _profile_id;
    BOOL _is_my_profile;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) ProfilesPageableDataProvider* friends_data_provider;
@property(nonatomic, retain) ProfilesPageableDataProvider* requests_in_data_provider;
@property(nonatomic, retain) ProfilesPageableDataProvider* requests_out_data_provider;
@property(nonatomic, retain) NSMutableArray<ProfilesPageableDataProvider*>* section_providers;
@property(nonatomic, retain) UITableView* table_view;

@end

@implementation ProfileFriendsViewController

-(instancetype)initWithProfileID:(anixart::ProfileID)profile_id isMyProfile:(BOOL)is_my_profile {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _profile_id = profile_id;
    _is_my_profile = is_my_profile;
    _section_providers = [NSMutableArray arrayWithCapacity:3];
    
    if (_is_my_profile) {
        _requests_in_data_provider = [[ProfilesPageableDataProvider alloc] initWithPages:_api_proxy.api->profiles().friend_requests_in(0)];
        _requests_out_data_provider = [[ProfilesPageableDataProvider alloc] initWithPages:_api_proxy.api->profiles().friend_requests_out(0)];
    }
    _friends_data_provider = [[ProfilesPageableDataProvider alloc] initWithPages:_api_proxy.api->profiles().get_friends(_profile_id, 0)];
    
    _friends_data_provider.delegate = self;
    _requests_in_data_provider.delegate = self;
    _requests_out_data_provider.delegate = self;
    
    [_friends_data_provider loadCurrentPage];
    [_requests_in_data_provider loadCurrentPage];
    [_requests_out_data_provider loadCurrentPage];
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}
-(void)setup {
    self.navigationItem.title = NSLocalizedString(@"app.profile_friends.title", "");

    _table_view = [UITableView new];
    [_table_view registerClass:ProfileTableViewCell.class forCellReuseIdentifier:[ProfileTableViewCell getIdentifier]];
    _table_view.dataSource = self;
    _table_view.delegate = self;
    _table_view.prefetchDataSource = self;
    
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
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)table_view {
    return [_section_providers count];
}

-(NSInteger)tableView:(UITableView*)table_view numberOfRowsInSection:(NSInteger)section {
    return [_section_providers[section] getItemsCount];
}

-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 80;
}

-(NSString *)tableView:(UITableView *)table_view titleForHeaderInSection:(NSInteger)section {
    ProfilesPageableDataProvider* data_provider = _section_providers[section];
    if (data_provider == _requests_in_data_provider) {
        return NSLocalizedString(@"app.profile_friends.requests_in.header", "");
    } else if (data_provider == _requests_out_data_provider) {
        return NSLocalizedString(@"app.profile_friends.requests_out.header", "");
    } else if (data_provider == _friends_data_provider) {
        return NSLocalizedString(@"app.profile_friends.friends.header", "");
    }
    return nil;
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path {
    ProfileTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ProfileTableViewCell getIdentifier] forIndexPath:index_path];
    NSInteger section = index_path.section;
    NSInteger index = index_path.row;
    
    anixart::Profile::Ptr profile = [_section_providers[section] getProfileAtIndex:index];
    
    NSURL* avatar_url = [NSURL URLWithString:TO_NSSTRING(profile->avatar_url)];
    NSString* friend_count = [NSString stringWithFormat:@"%d %@", profile->friend_count, NSLocalizedString(@"app.profile_friends.friends_count.end", "")];
    
    [cell setAvatarUrl:avatar_url];
    [cell setUsername:TO_NSSTRING(profile->username)];
    [cell setFriendCount:friend_count];
    [cell setIsOnline:profile->is_online];
    
    return cell;
}

-(void)tableView:(UITableView*)table_view
prefetchRowsAtIndexPaths:(NSArray<NSIndexPath*>*)index_paths {
    BOOL section_loaded = NO;
    NSInteger section = index_paths[0].section;
    NSUInteger item_count = [self tableView:_table_view numberOfRowsInSection:section];
    
    for (NSIndexPath* index_path in index_paths) {
        if (section_loaded) continue;
        
        if (section != index_path.section) {
            section = index_path.section;
            item_count = [self tableView:_table_view numberOfRowsInSection:section];
            section_loaded = NO;
        }
        if (index_path.row >= item_count - 1) {
            [_section_providers[section] loadNextPage];
            section_loaded = YES;
        }
    }
}

-(UIContextMenuConfiguration *)tableView:(UITableView *)table_view contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)index_path point:(CGPoint)point {
    NSInteger section = index_path.section;
    NSInteger index = index_path.row;
    return [_section_providers[section] getContextMenuConfigurationForItemAtIndex:index];
}

-(void)tableView:(UITableView*)table_view didSelectRowAtIndexPath:(NSIndexPath*)index_path {
    [table_view deselectRowAtIndexPath:index_path animated:YES];
    NSInteger section = index_path.section;
    NSInteger index = index_path.row;
    
    anixart::Profile::Ptr profile = [_section_providers[section] getProfileAtIndex:index];
    if (!profile) {
        return;
    }
    
    [self.navigationController pushViewController:[[ProfileViewController alloc] initWithProfileID:profile->id] animated:YES];
}

-(void)didUpdateDataForPageableDataProvider:(PageableDataProvider*)pageable_data_provider {
    [_table_view reloadData];
}

-(void)pageableDataProvider:(PageableDataProvider*)pageable_data_provider didLoadPageAtIndex:(NSInteger)page_index {
    if (![pageable_data_provider isKindOfClass:ProfilesPageableDataProvider.class]) {
        return;
    }
    
    ProfilesPageableDataProvider* profiles_data_provider = static_cast<ProfilesPageableDataProvider*>(pageable_data_provider);
    if ([_section_providers containsObject:profiles_data_provider] || [profiles_data_provider getItemsCount] == 0) {
        return;
    }
    if (profiles_data_provider == _requests_in_data_provider) {
        [_section_providers insertObject:profiles_data_provider atIndex:0];
    } else if (profiles_data_provider == _requests_out_data_provider) {
        NSInteger index = [_section_providers containsObject:_requests_in_data_provider] ? 1 : 0;
        [_section_providers insertObject:profiles_data_provider atIndex:index];
    } else if (profiles_data_provider == _friends_data_provider) {
        [_section_providers addObject:profiles_data_provider];
    }
    
    [_table_view reloadData];
}

@end
