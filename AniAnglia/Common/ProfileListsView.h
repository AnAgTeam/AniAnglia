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

-(instancetype)initWithRelease:(anixart::Release::Ptr)release;
-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile;
-(instancetype)initWithCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info;

-(void)setFromRelease:(anixart::Release::Ptr)release;
-(void)setFromProfile:(anixart::Profile::Ptr)profile;
-(void)setFromCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info;

@end

#endif /* ProfileListsView_h */
