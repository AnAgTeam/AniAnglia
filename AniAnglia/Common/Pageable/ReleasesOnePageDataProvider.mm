//
//  ReleasesOnePageDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 15.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleasesOnePageDataProvider.h"

@interface ReleasesOnePageDataProvider () {
    std::vector<anixart::Release::Ptr> _releases;
}

@end

@implementation ReleasesOnePageDataProvider

-(instancetype)initWithReleases:(std::vector<anixart::Release::Ptr>)releases {
    self = [super initWithPages:nullptr];
    
    return self;
}

-(BOOL)isEnd {
    return YES;
}
-(size_t)getItemsCount {
    return _releases.size();
}
-(anixart::Release::Ptr)getReleaseAtIndex:(NSInteger)index {
    if (index >= _releases.size()) {
        return nullptr;
    }
    return _releases[index];
}

-(void)loadCurrentPage {
    [self callDelegateDidLoadPageAtIndex:0];
}
-(void)loadCurrentPageIfNeeded {
    [self callDelegateDidLoadPageAtIndex:0];
}
-(void)loadNextPage {
    
}

@end
