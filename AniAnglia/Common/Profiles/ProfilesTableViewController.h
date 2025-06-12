//
//  ProfilesTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.06.2025.
//

#ifndef ProfilesTableViewController_h
#define ProfilesTableViewController_h

#import <UIKit/UIKit.h>
#import "ProfilesPageableDataProvider.h"

@interface ProfilesTableViewController : UITableViewController <PageableDataProviderDelegate>
@property(nonatomic) BOOL is_container_view_controller;
@property(nonatomic) BOOL auto_page_load_disabled;

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Profile>::UPtr)pages;
-(instancetype)initWithTableView:(UITableView*)table_view dataProvider:(ProfilesPageableDataProvider*)data_provider;

-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages;
-(void)setDataProvider:(ProfilesPageableDataProvider*)data_provider;
-(void)reset;

-(void)reloadData;

-(void)setHeaderView:(UIView*)header_view;

// can override in derived classes to change cell display
-(void)tableViewDidLoad;
-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path;
-(__kindof UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path withProfile:(anixart::Profile::Ptr)profile;
@end

#endif /* ProfilesTableViewController_h */
