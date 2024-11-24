//
//  ReleasesSearchHistoryView.h
//  AniAnglia
//
//  Created by Toilettrauma on 24.11.2024.
//

#import <UIKit/UIKit.h>
#import "NavSearchViewController.h"

@interface ReleasesSearchHistoryView : NavigationSearchInlineView <UITableViewDelegate, UITableViewDataSource>
-(instancetype)init;
-(void)searchTextDidChanged:(NSString*)text;
@end
