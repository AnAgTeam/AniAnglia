//
//  SearchReleasesViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <Foundation/Foundation.h>
#import "SearchReleasesTableView.h"

@interface SearchReleasesTableView () {
    id<SearchReleasesTableViewDelegate> _delegate;
}

@end

@implementation SearchReleasesTableView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    
    return self;
}

-(void)setup {
    _releases_table_view = [ReleasesTableView new];
    _releases_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_releases_table_view];
    [_releases_table_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_releases_table_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_releases_table_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_releases_table_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}
-(void)setupLayout {
    
}

-(void)setDataSource:(id<SearchReleasesTableViewDataSource>)data_source {
    _releases_table_view.data_source = data_source;
    _data_source = data_source;
}
-(id<SearchReleasesTableViewDataSource>)dataSource {
    return _data_source;
}
-(void)setDelegate:(id<SearchReleasesTableViewDelegate>)delegate {
    _releases_table_view.delegate = delegate;
    _delegate = delegate;
}
-(id<SearchReleasesTableViewDelegate>)delegate {
    return _delegate;
}

-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller query:(NSString*)query {
    [_data_source searchReleasesTableView:self willBeginRequestsWithQuery:query];
    [_releases_table_view releasesTableViewDidShow];
}

@end
