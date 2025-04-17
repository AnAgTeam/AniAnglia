//
//  SearchViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 12.03.2025.
//

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ReleasesTableViewController : UIViewController
@property(nonatomic) BOOL is_container_view_controller;
@property(nonatomic) BOOL trailing_action_disabled;
@property(nonatomic) BOOL auto_page_load_disabled;

-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(instancetype)initWithTableView:(UITableView*)table_view pages:(anixart::Pageable<anixart::Release>::UPtr)pages trailingActionDisabled:(BOOL)trailing_action_disabled;
-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages trailingActionDisabled:(BOOL)trailing_action_disabled;

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages;
-(void)reset;

-(void)setHeaderView:(UIView*)header_view;
@end
