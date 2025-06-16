//
//  ReleasesHistoryTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesHistoryTableViewController.h"
#import "ReleaseHistoryTableViewCells.h"
#import "StringCvt.h"
#import "TimeCvt.h"

@interface ReleasesHistoryTableViewController ()

@end

@implementation ReleasesHistoryTableViewController

-(void)tableViewDidLoad {
    [self.tableView registerClass:ReleaseHistoryTableViewCell.class forCellReuseIdentifier:[ReleaseHistoryTableViewCell getIdentifier]];
}
-(CGFloat)tableView:(UITableView *)table_view heightForRowAtIndexPath:(NSIndexPath *)index_path {
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)table_view cellForRowAtIndexPath:(NSIndexPath *)index_path withRelease:(anixart::Release::Ptr)release {
    ReleaseHistoryTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleaseHistoryTableViewCell getIdentifier] forIndexPath:index_path];

    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    NSString* time = [NSDateFormatter localizedStringFromDate:anix_time_point_to_nsdate(release->last_view_date) dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setEpisode:TO_NSSTRING(release->last_view_episode->name)];
    [cell setTime:time];
    
    return cell;
}

@end
