//
//  ProfilesPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfilesPageableDataProvider.h"

@interface ProfilesPageableDataProvider () {
    anixart::Pageable<anixart::Profile>::UPtr _pages;
    std::vector<anixart::Profile::Ptr> _profiles;
}
@property(nonatomic, strong) LibanixartApi* api_proxy;
@property(nonatomic, retain) NSLock* lock;

@end

@implementation ProfilesPageableDataProvider : NSObject

-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    _pages = std::move(pages);
    
    return self;
}

-(void)reset {
    // TODO: load cancel
    _profiles.clear();
}
-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    _profiles.clear();
    _pages = std::move(pages);
    [self loadCurrentPage];
}

-(BOOL)isEnd {
    return _pages->is_end();
}
-(size_t)getItemsCount {
    return _profiles.size();
}
-(anixart::Profile::Ptr)getProfileAtIndex:(NSInteger)index {
    if (index >= _profiles.size()) {
        // wtf
        return nullptr;
    }
    return _profiles[index];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Profile::Ptr>(^)())block {
    if (!_pages) {
        return;
    }
    
    [_api_proxy performAsyncBlock:^BOOL(anixart::Api* api){
        /* todo: change to thread-safe */
        auto new_items = block();
//        [self->_lock lock];
        self->_profiles.insert(self->_profiles.end(), new_items.begin(), new_items.end());
//        [self->_lock unlock];
        return YES;
    } withUICompletion:^{
        [self->_delegate didUpdatedDataForProfilesPageableDataProvider:self];
    }];
}

-(void)loadCurrentPage {
    [self appendItemsFromBlock:^() {
        return self->_pages->get();
    }];
}
-(void)loadNextPage {
    if (_pages->is_end()) {
        return;
    }
    [self appendItemsFromBlock:^() {
        return self->_pages->next();
    }];
}

@end

