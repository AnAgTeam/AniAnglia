//
//  ReleasesPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 20.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesPageableDataProvider.h"
#import "ProfileListsView.h"

@interface ReleasesPageableDataProvider () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    std::vector<anixart::Release::Ptr> _releases;
}

@end

@implementation ReleasesPageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages initialReleases:(std::vector<anixart::Release::Ptr>)releases {
    self = [self initWithPages:std::move(pages)];
    
    _releases = std::move(releases);
    
    return self;
}

-(void)reset {
    // TODO: load cancel
    _releases.clear();
    [self callDelegateDidUpdated];
}
-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    _releases.clear();
    _pages = std::move(pages);
    [self callDelegateDidUpdated];
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
    [self setItemsFromBlock:block isAppend:YES];
}

-(void)setItemsFromBlock:(std::vector<anixart::Release::Ptr>(^)())block isAppend:(BOOL)is_append {
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
            self->_releases.insert(self->_releases.end(), new_items.begin(), new_items.end());
        } else {
            self->_releases = std::move(new_items);
        }
        [self callDelegateDidLoadedPageAtIndex:self->_pages->get_current_page()];
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

-(UIContextMenuConfiguration *)getContextMenuConfigurationForItemAtIndex:(NSInteger)index {
    if (index >= _releases.size()) {
        return nil;
    }
    anixart::Release::Ptr release = _releases[index];
    
    UIMenu* list_menu = [UIMenu menuWithTitle:NSLocalizedString(@"app.release.list_status.add", "") image:[UIImage systemImageNamed:@"line.3.horizontal"] identifier:nil options:0 children:@[
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::NotWatching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::NotWatching];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Watching] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::Watching];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Plan] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::Plan];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Watched] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::Watched];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::HoldOn] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::HoldOn];
        }],
        [UIAction actionWithTitle:[ProfileListsView getListStatusName:anixart::Profile::ListStatus::Dropped] image:nil identifier:nil handler:^(UIAction* action) {
            [self onAddListContextMenuAtIndex:index listStatus:anixart::Profile::ListStatus::Dropped];
        }]
    ]];
    UIAction* bookmark_action;
    if (release->is_favorite) {
        bookmark_action = [UIAction actionWithTitle:NSLocalizedString(@"app.release.bookmark.remove", "") image:[UIImage systemImageNamed:@"bookmark.slash"] identifier:nil handler:^(UIAction* action){
            [self onBookmarkContextMenuAtIndex:index bookmark:NO];
        }];
    } else {
        bookmark_action = [UIAction actionWithTitle:NSLocalizedString(@"app.release.bookmark.add", "") image:[UIImage systemImageNamed:@"bookmark"] identifier:nil handler:^(UIAction* action){
            [self onBookmarkContextMenuAtIndex:index bookmark:YES];
        }];
    }
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^(NSArray* suggested_actions) {
        return [UIMenu menuWithChildren:@[
            bookmark_action,
            list_menu
        ]];
    }];
}

-(void)onAddListContextMenuAtIndex:(NSInteger)index listStatus:(anixart::Profile::ListStatus)list_status{
    anixart::Release::Ptr release = _releases[index];
    
    [self.api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().add_release_to_profile_list(release->id, list_status);
        return YES;
    } withUICompletion:^{
        [self callDelegateDidUpdated];
    }];
}
-(void)onBookmarkContextMenuAtIndex:(NSInteger)index bookmark:(BOOL)bookmark {
    anixart::Release::Ptr release = _releases[index];
    
    [self.api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (bookmark) {
            api->releases().add_release_to_favorites(release->id);
        } else {
            api->releases().remove_release_from_favorites(release->id);
        }
        return YES;
    } withUICompletion:^{
        [self callDelegateDidUpdated];
    }];
}


@end
