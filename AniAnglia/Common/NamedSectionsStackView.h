//
//  NamedSectionsStackView.h
//  AniAnglia
//
//  Created by Toilettrauma on 14.06.2025.
//

#ifndef NamedSectionsStackView_h
#define NamedSectionsStackView_h

#import <UIKit/UIKit.h>
#import "NamedSectionView.h"

@interface RelativeNamedSectionView : NamedSectionView
@property(nonatomic) NSInteger relative_index;

@end

@interface NamedSectionsStackView : UIStackView

-(instancetype)init;

-(void)addRelativeNamedSection:(RelativeNamedSectionView*)named_section_view;

//-(void)updatePositioning;

@end


#endif /* NamedSectionsStackView_h */
