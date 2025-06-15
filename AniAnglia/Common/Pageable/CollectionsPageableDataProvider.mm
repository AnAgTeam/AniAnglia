//
//  CollectionsPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 15.06.2025.
//

#import <Foundation/Foundation.h>
#import "CollectionsPageableDataProvider.h"
#import "StringCvt.h"

@interface CollectionsPageableDataProvider () {
    anixart::Pageable<anixart::Collection>::UPtr _pages;
    std::vector<anixart::Collection::Ptr> _collections;
}
@property(nonatomic) BOOL is_needed_first_load;

@end

@implementation CollectionsPageableDataProvider

-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages {
    self = [super init];
    
    _pages = std::move(pages);
    _is_needed_first_load = static_cast<bool>(_pages);
    
    return self;
}

-(instancetype)initWithPages:(anixart::Pageable<anixart::Collection>::UPtr)pages initialCollections:(std::vector<anixart::Collection::Ptr>)collections {
    self = [self initWithPages:std::move(pages)];
    
    _collections = std::move(collections);
    
    return self;
}

-(void)clear {
    // TODO: load cancel
    _collections.clear();
    [self callDelegateDidUpdate];
}

-(void)reload {
    _collections.clear();
    [self callDelegateDidUpdate];
    [self loadPageAtIndex:0];
}

-(void)refresh {
    [self loadPageAtIndex:0];
}

-(void)setPages:(anixart::Pageable<anixart::Collection>::UPtr)pages {
    _collections.clear();
    _pages = std::move(pages);
    [self callDelegateDidUpdate];
    [self loadCurrentPage];
}

-(BOOL)isEnd {
    if (!_pages) {
        return YES;
    }
    return _pages->is_end();
}

-(size_t)getItemsCount {
    return _collections.size();
}

-(anixart::Collection::Ptr)getCollectionAtIndex:(NSInteger)index {
    if (index >= _collections.size()) {
        return nullptr;
    }
    return _collections[index];
}

-(void)appendItemsFromBlock:(std::vector<anixart::Collection::Ptr>(^)())block {
    [self setItemsFromBlock:block isAppend:YES];
}

-(void)setItemsFromBlock:(std::vector<anixart::Collection::Ptr>(^)())block isAppend:(BOOL)is_append {
    if (!_pages) {
        return;
    }
    
    __block decltype(block()) new_items;
    [self.api_proxy asyncCall:^BOOL(anixart::Api* api) {
        new_items = block();
        return NO;
    } completion:^(BOOL errored) {
        if (errored) {
            [self callDelegateDidFailPageAtIndex:self->_pages->get_current_page()];
            return;
        }
        if (is_append) {
            self->_collections.insert(self->_collections.end(), new_items.begin(), new_items.end());
        } else {
            self->_collections = std::move(new_items);
        }
        [self callDelegateDidLoadPageAtIndex:self->_pages->get_current_page()];
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
        return;
    }
    
    if (_pages) {
        [self callDelegateDidLoadPageAtIndex:_pages->get_current_page()];
    } else {
        [self callDelegateDidLoadPageAtIndex:0];
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

-(UIContextMenuConfiguration *)getContextMenuConfigurationForItemAtIndex:(NSInteger)index {
    if (index >= _collections.size()) {
        return nil;
    }
    anixart::Collection::Ptr collection = _collections[index];
    

    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^(NSArray* suggested_actions) {
        return [UIMenu menuWithChildren:@[

        ]];
    }];
}

@end
