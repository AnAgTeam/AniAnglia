//
//  SearchReleasesView.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <UIKit/UIKit.h>
#import "NavSearchViewController.h"
#import "ReleasesTableView.h"

@interface SearchReleasesTableView : NavigationSearchView
-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller query:(NSString*)query;
-(void)reloadWithText:(NSString*)text;
@end
