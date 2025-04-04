//
//  ProfileListsView.h
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#ifndef ProfileListsView_h
#define ProfileListsView_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface ProfileListLegendView : UIView

-(instancetype)initWithLegendName:(NSString*)name color:(UIColor*)color count:(NSInteger)count;
@end

@interface ProfileListsView : UIView 

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release name:(NSString*)name;
-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile name:(NSString*)name;
@end

#endif /* ProfileListsView_h */
