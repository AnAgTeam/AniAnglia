//
//  ReleasesOnePageDataProvider.h
//  AniAnglia
//
//  Created by Toilettrauma on 15.06.2025.
//

#ifndef ReleasesOnePageDataProvider_h
#define ReleasesOnePageDataProvider_h

#import <UIKit/UIKit.h>
#import "ReleasesPageableDataProvider.h"

@interface ReleasesOnePageDataProvider : ReleasesPageableDataProvider

-(instancetype)initWithReleases:(std::vector<anixart::Release::Ptr>)releases;

@end


#endif /* ReleasesOnePageDataProvider_h */
