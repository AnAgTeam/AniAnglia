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

+(UIColor*)getColorForListStatus:(anixart::Profile::ListStatus)list_status;
+(NSString*)getListStatusName:(anixart::Profile::ListStatus)list_status;

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release name:(NSString*)name;
-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile name:(NSString*)name;
-(instancetype)initWithCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info name:(NSString*)name;

-(void)setReleaseInfo:(anixart::Release::Ptr)release;
-(void)setProfile:(anixart::Profile::Ptr)profile;
@end

#endif /* ProfileListsView_h */
