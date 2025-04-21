//
//  ReleasesPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 20.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesPageableDataProvider.h"

@interface ReleasesPageableDataProvider () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    std::vector<anixart::Release::Ptr> _releases;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) NSLock* lock;

@end

@implementation ReleasesPageableDataProvider : NSObject

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _pages = std::move(pages);
    [self loadCurrentPage];
    
    return self;
}

-(void)reset {
    // TODO: load cancel
    _releases.clear();
}
-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    _releases.clear();
    _pages = std::move(pages);
    [self loadCurrentPage];
}

-(BOOL)isEnd {
    return _pages->is_end();
}
-(size_t)getItemsCount {
    return _releases.size();
}
-(anixart::Release::Ptr)getReleaseAtIndex:(NSInteger)index {
    if (index >= _releases.size()) {
        // wtf
        return nullptr;
    }
    return _releases[index];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Release::Ptr>(^)())block {
    if (!_pages) {
        return;
    }
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        /* todo: change to thread-safe */
        auto new_items = block();
//        [self->_lock lock];
        self->_releases.insert(self->_releases.end(), new_items.begin(), new_items.end());
//        [self->_lock unlock];
        return YES;
    } withUICompletion:^{
        [self->_delegate releasesPageableDataProvider:self didLoadedPageWithIndex:self->_pages->get_current_page()];
    }];
}

-(void)loadCurrentPage {
    [self appendItemsFromBlock:^() {
        return self->_pages->get();
    }];
}
-(void)loadNextPage {
    [self appendItemsFromBlock:^() {
        return self->_pages->next();
    }];

}

@end
