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


-(void)callDelegateDidUpdate {
    [_delegate didUpdateDataForPageableDataProvider:self];
}
-(void)callDelegateDidLoadPageAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pageableDataProvider:didLoadPageAtIndex:)]) {
        [_delegate pageableDataProvider:self didLoadPageAtIndex:index];
    }
}
-(void)callDelegateDidFailPageAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pageableDataProvider:didFailPageAtIndex:)]) {
        [_delegate pageableDataProvider:self didFailPageAtIndex:index];
    }
}

@end
