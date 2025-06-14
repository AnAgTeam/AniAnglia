//
//  ReleasesPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 20.04.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesPageableDataProvider.h"
#import "ProfileListsView.h"
#import "StringCvt.h"

@interface ReleasesPageableDataProvider () {
    anixart::Pageable<anixart::Release>::UPtr _pages;
    std::vector<anixart::Release::Ptr> _releases;
}
@property(nonatomic, readonly) BOOL is_needed_first_load;

@end

@implementation ReleasesPageableDataProvider

+(NSString*)getSeasonNameFor:(anixart::Release::Season)season {
    switch (season) {
        case anixart::Release::Season::Winter:
            return NSLocalizedString(@"app.release.season.winter", "");
        case anixart::Release::Season::Spring:
            return NSLocalizedString(@"app.release.season.spring", "");
        case anixart::Release::Season::Summer:
            return NSLocalizedString(@"app.release.season.summer", "");
        case anixart::Release::Season::Fall:
            return NSLocalizedString(@"app.release.season.fall", "");
        default:
            return NSLocalizedString(@"app.release.season.unknown", "");
    }
}

+(NSString*)getCategoryNameFor:(anixart::Release::Category)category {
    switch (category) {
        case anixart::Release::Category::Series:
            return NSLocalizedString(@"app.release.category.series", "");
        case anixart::Release::Category::Movies:
            return NSLocalizedString(@"app.release.category.movies", "");
        case anixart::Release::Category::Ova:
            return NSLocalizedString(@"app.release.category.ova", "");
        default:
            return NSLocalizedString(@"app.release.category.unknown", "");
    }
}

+(NSString*)getStatusNameFor:(anixart::Release::Status)status {
    switch (status) {
        case anixart::Release::Status::Finished:
            return NSLocalizedString(@"app.release.status.finished", "");
        case anixart::Release::Status::Ongoing:
            return NSLocalizedString(@"app.release.status.ongoing", "");
        case anixart::Release::Status::Upcoming:
            return NSLocalizedString(@"app.release.status.upcoming", "");
        default:
            return NSLocalizedString(@"app.release.status.unknown", "");
    }
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    _is_needed_first_load = static_cast<bool>(_pages);
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Release>::UPtr)pages initialReleases:(std::vector<anixart::Release::Ptr>)releases {
    self = [self initWithPages:std::move(pages)];
    
    _releases = std::move(releases);
    
    return self;
}

-(void)clear {
    // TODO: load cancel
    _releases.clear();
    [self callDelegateDidUpdated];
}

-(void)reload {
    _releases.clear();
    [self callDelegateDidUpdated];
    [self loadPageAtIndex:0];
}

-(void)refresh {
    [self loadPageAtIndex:0];
}

-(void)setPages:(anixart::Pageable<anixart::Release>::UPtr)pages {
    _releases.clear();
    _pages = std::move(pages);
    [self callDelegateDidUpdated];
    [self loadCurrentPage];
}

-(BOOL)isEnd {
    if (!_pages) {
        return true;
    }
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
    _is_needed_first_load = NO;
    [self appendItemsFromBlock:^() {
        return self->_pages->get();
    }];
}

-(void)loadCurrentPageIfNeeded {
    if (_is_needed_first_load) {
        [self loadCurrentPage];
    }
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
    [self setItemsFromBlock:^{
        return strong_self->_pages->go(static_cast<int32_t>(index));
    } isAppend:NO];
}

-(UIAction*)makeContextMenuAction:(anixart::Profile::ListStatus)list_status toRelease:(anixart::Release::Ptr)release {
    UIImage* image = list_status == release->profile_list_status ? [UIImage systemImageNamed:@"checkmark"] : nil;
    return [UIAction actionWithTitle:[ProfileListsView getListStatusName:list_status] image:image identifier:nil handler:^(UIAction* action) {
        [self onAddListContextMenu:list_status withRelease:release];
    }];
}

-(UIContextMenuConfiguration *)getContextMenuConfigurationForItemAtIndex:(NSInteger)index {
    if (index >= _releases.size()) {
        return nil;
    }
    anixart::Release::Ptr release = _releases[index];
    
    UIMenu* list_menu = [UIMenu menuWithTitle:NSLocalizedString(@"app.release.list_status.add", "") image:[UIImage systemImageNamed:@"line.3.horizontal"] identifier:nil options:0 children:@[
        [self makeContextMenuAction:anixart::Profile::ListStatus::NotWatching toRelease:release],
        [self makeContextMenuAction:anixart::Profile::ListStatus::Watching toRelease:release],
        [self makeContextMenuAction:anixart::Profile::ListStatus::Plan toRelease:release],
        [self makeContextMenuAction:anixart::Profile::ListStatus::Watched toRelease:release],
        [self makeContextMenuAction:anixart::Profile::ListStatus::HoldOn toRelease:release],
        [self makeContextMenuAction:anixart::Profile::ListStatus::Dropped toRelease:release]
    ]];
    UIAction* bookmark_action;
    if (release->is_favorite) {
        bookmark_action = [UIAction actionWithTitle:NSLocalizedString(@"app.release.bookmark.remove", "") image:[UIImage systemImageNamed:@"bookmark.slash"] identifier:nil handler:^(UIAction* action){
            [self onBookmarkContextMenu:NO withRelease:release];
        }];
    } else {
        bookmark_action = [UIAction actionWithTitle:NSLocalizedString(@"app.release.bookmark.add", "") image:[UIImage systemImageNamed:@"bookmark"] identifier:nil handler:^(UIAction* action){
            [self onBookmarkContextMenu:YES withRelease:release];
        }];
    }
    
    UIMenu* copy_menu = [UIMenu menuWithTitle:NSLocalizedString(@"app.release.copy", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil options:0 children:@[
        [UIAction actionWithTitle:NSLocalizedString(@"app.release.copy_title", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
            [self onCopyTitleContextMenuWithRelease:release];
        }],
        [UIAction actionWithTitle:NSLocalizedString(@"app.release.copy_orig_title", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
            [self onCopyOrigTitleContextMenuWithRelease:release];
        }],
        [UIAction actionWithTitle:NSLocalizedString(@"app.release.copy_alt_title", "") image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction* action) {
            [self onCopyAltTitleContextMenuWithRelease:release];
        }],
    ]];
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^(NSArray* suggested_actions) {
        return [UIMenu menuWithChildren:@[
            bookmark_action,
            list_menu,
            copy_menu
        ]];
    }];
}

-(void)onAddListContextMenu:(anixart::Profile::ListStatus)list_status withRelease:(anixart::Release::Ptr)release {
    [self.api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        api->releases().add_release_to_profile_list(release->id, list_status);
        return YES;
    } withUICompletion:^{
        // possible violation
        release->profile_list_status = list_status;
        [self callDelegateDidUpdated];
    }];
}

-(void)onBookmarkContextMenu:(BOOL)bookmarked withRelease:(anixart::Release::Ptr)release {
    [self.api_proxy performAsyncBlock:^BOOL(anixart::Api* api) {
        if (bookmarked) {
            api->releases().add_release_to_favorites(release->id);
        } else {
            api->releases().remove_release_from_favorites(release->id);
        }
        return YES;
    } withUICompletion:^{
        // possible violation
        release->is_favorite = bookmarked;
        [self callDelegateDidUpdated];
    }];
}

-(void)onCopyTitleContextMenuWithRelease:(anixart::Release::Ptr)release {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(release->title_ru);
}

-(void)onCopyOrigTitleContextMenuWithRelease:(anixart::Release::Ptr)release {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(release->title_original);
}

-(void)onCopyAltTitleContextMenuWithRelease:(anixart::Release::Ptr)release {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = TO_NSSTRING(release->title_alt);
}


@end
