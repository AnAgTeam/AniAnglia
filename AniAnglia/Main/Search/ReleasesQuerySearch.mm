//
//  ReleaseQuerySearchView.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.12.2024.
//

#import <Foundation/Foundation.h>
#import "ReleasesQuerySearch.h"
#import "LibanixartApi.h"
#import "StringCvt.h"
#import "ReleaseViewController.h"

@interface ReleasesQuerySearchDefaultDataSource () {
    libanixart::ReleaseSearchPages::UniqPtr _search_release_pages;
}
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic) std::vector<libanixart::Release::Ptr> search_releases;

@end

@implementation ReleasesQuerySearchDefaultDataSource

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    
    return self;
}

-(void)searchReleasesTableView:(SearchReleasesTableView*)releases_view willBeginRequestsWithQuery:(NSString*)query {
    NSLog(@"Search query: %@", query);
    libanixart::requests::SearchRequest search_req;
    search_req.query = TO_STDSTRING(query);
    _search_release_pages = _api_proxy.api->search().release_search(search_req);
    _search_releases.clear();
}

-(void)releasesTableView:(SearchReleasesTableView*)releases_view loadPage:(NSUInteger)page completionHandler:(void(^)(BOOL should_continue_fetch))completion_handler {
    __block BOOL should_continue_fetch = YES;
    [_api_proxy performAsyncBlock:^BOOL(libanixart::Api* api){
        auto new_items = self->_search_release_pages->go(page);
        self->_search_releases.insert(self->_search_releases.end(), new_items.begin(), new_items.end());
        should_continue_fetch = !self->_search_release_pages->is_end();
        return YES;
    } withUICompletion:^{
        completion_handler(should_continue_fetch);
    }];
}
-(void)releasesTableView:(SearchReleasesTableView*)releases_view loadNextPageWithcompletionHandler:(void(^)(BOOL action_performed))completion_handler {
    __block BOOL action_performed = YES;
    [_api_proxy performAsyncBlock:^BOOL(libanixart::Api* api){
        auto new_items = self->_search_release_pages->next();
        self->_search_releases.insert(self->_search_releases.end(), new_items.begin(), new_items.end());
        action_performed = !self->_search_release_pages->is_end();
        return YES;
    } withUICompletion:^{
        completion_handler(action_performed);
    }];
}
-(libanixart::Release::Ptr)releasesTableView:(SearchReleasesTableView*)releases_view releaseAtIndex:(NSUInteger)index {
    return _search_releases[index];
}
-(NSUInteger)numberOfItemsForReleasesTableView:(SearchReleasesTableView*)releases_view {
    return _search_releases.size();
}

@end

@implementation ReleasesQuerySearchDefaultDelegate

-(void)releasesTableView:(SearchReleasesTableView*)releases_view didSelectReleaseAtIndex:(NSInteger)index {
    /* !!!! */
}


@end
