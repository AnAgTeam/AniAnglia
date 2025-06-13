//
//  ReleasesRelatedTableViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 13.06.2025.
//

#ifndef ReleasesRelatedTableViewController_h
#define ReleasesRelatedTableViewController_h

#import <UIKit/UIKit.h>
#import "ReleasesTableViewController.h"

@interface ReleaseRelatedTableViewCell : UITableViewCell
+(NSString*)getIdentifier;

-(void)setImageUrl:(NSURL*)url;
-(void)setTitle:(NSString*)title;
-(void)setYear:(NSString*)year;
-(void)setRating:(NSString*)rating;
-(void)setCategory:(NSString*)category;
@end

@interface ReleaseRelatedTableViewController : ReleasesTableViewController

@end


#endif /* ReleasesRelatedTableViewController_h */
