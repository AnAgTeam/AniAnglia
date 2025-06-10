//
//  GenericPageableDataProvider.m
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#import <Foundation/Foundation.h>
#import "PageableDataProvider.h"

@interface PageableDataProvider ()
@end

@implementation PageableDataProvider

-(instancetype)init {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _lock = [NSLock new];
    
    return self;
}


-(void)callDelegateDidUpdated {
    [_delegate didUpdatedDataForPageableDataProvider:self];
}
-(void)callDelegateDidLoadedPageAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pageableDataProvider:didLoadedPageAtIndex:)]) {
        [_delegate pageableDataProvider:self didLoadedPageAtIndex:index];
    }
}
-(void)callDelegateDidFailedPageAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pageableDataProvider:didFailedPageAtIndex:)]) {
        [_delegate pageableDataProvider:self didFailedPageAtIndex:index];
    }
}

@end
