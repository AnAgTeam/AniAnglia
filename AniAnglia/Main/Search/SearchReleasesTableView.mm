//
//  SearchReleasesViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.11.2024.
//

#import <Foundation/Foundation.h>
#import "SearchReleasesTableView.h"
#import "StringCvt.h"

@interface SearchReleasesTableView ()
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) ReleasesTableView* releases_view;
@end

@implementation SearchReleasesTableView

-(instancetype)init {
    self = [super init];
    
    [self setup];
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)setup {
    _releases_view = [ReleasesTableView new];
    [self addSubview:_releases_view];
    _releases_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_releases_view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_releases_view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_releases_view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_releases_view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [self setupLayout];
}
-(void)setupLayout {
    self.backgroundColor = [UIColor clearColor];
}

-(void)searchViewDidShowWithController:(NavigationSearchViewController*)view_controller query:(NSString*)query {
    libanixart::requests::SearchRequest request;
    request.query = TO_STDSTRING(query);
    [_releases_view setPages:_api_proxy.api->search().release_search(request)];
}
-(void)reloadWithText:(NSString*)text {
    
}
@end
