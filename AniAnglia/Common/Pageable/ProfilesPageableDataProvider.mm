//
//  ProfilesPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 21.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfilesPageableDataProvider.h"
#import "StringCvt.h"

@interface ProfilesPageableDataProvider () {
    anixart::Pageable<anixart::Profile>::UPtr _pages;
    std::vector<anixart::Profile::Ptr> _profiles;
}

@end

@implementation ProfilesPageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Profile>::UPtr)pages initialProfiles:(std::vector<anixart::Profile::Ptr>)profiles {
    self = [super init];
    
    _pages = std::move(pages);
    _profiles = profiles;
    
    return self;
}

-(void)clear {
    _profiles.clear();
    [self callDelegateDidUpdated];
}
-(void)reset {
    [self loadPageAtIndex:0];
}
-(void)setPages:(anixart::Pageable<anixart::Profile>::UPtr)pages {
    _profiles.clear();
    _pages = std::move(pages);
    [self callDelegateDidUpdated];
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

-(void)setItemsFromBlock:(std::vector<anixart::Profile::Ptr>(^)())block isAppend:(BOOL)is_append {
    if (!_pages) {
        return;
    }
    
    __block decltype(block()) new_items;
    [self.api_proxy asyncCall:^BOOL(anixart::Api* api) {
        new_items = block();
        return NO;
    } completion:^(BOOL errored) {
        if (errored) {
            [self callDelegateDidFailedPageAtIndex:self->_pages->get_current_page()];
            return;
        }
        if (is_append) {
            self->_profiles.insert(self->_profiles.end(), new_items.begin(), new_items.end());
        } else {
            self->_profiles = std::move(new_items);
        }
        [self callDelegateDidLoadedPageAtIndex:self->_pages->get_current_page()];
    }];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Profile::Ptr>(^)())block {
    [self setItemsFromBlock:block isAppend:YES];
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

-(void)loadPageAtIndex:(NSInteger)index {
    __strong auto strong_self = self;
    [self setItemsFromBlock:^() {
        return strong_self->_pages->go(static_cast<int32_t>(index));
    } isAppend:NO];
}

-(UIContextMenuConfiguration*)getContextMenuConfigurationForItemAtIndex:(NSInteger)index {
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^(NSArray* suggested_actions) {
        return [UIMenu menuWithChildren:@[
            [UIAction actionWithTitle:NSLocalizedString(@"app.profile.copy_username", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
                [self onCopyUsernameSelectedAtIndex:index];
            }]
        ]];
    }];
}

-(void)onCopyUsernameSelectedAtIndex:(NSInteger)index {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(_profiles[index]->username);
}

@end

