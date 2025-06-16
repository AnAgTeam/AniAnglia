//
//  NamedSectionsStackView.m
//  AniAnglia
//
//  Created by Toilettrauma on 14.06.2025.
//

#import <Foundation/Foundation.h>
#import "NamedSectionsStackView.h"

@interface RelativeNamedSectionView ()

@end

@interface NamedSectionsStackView ()

@end

@implementation RelativeNamedSectionView

@end


@implementation NamedSectionsStackView

-(instancetype)init {
    self = [super init];
    
    return self;
}

-(void)addRelativeNamedSection:(RelativeNamedSectionView*)named_section_view {
    for (size_t i = 0; i < [self.arrangedSubviews count]; ++i) {
        RelativeNamedSectionView* my_named_section = static_cast<RelativeNamedSectionView*>(self.arrangedSubviews[i]);
        if (my_named_section.relative_index > named_section_view.relative_index) {
            [self insertArrangedSubview:named_section_view atIndex:i];
            return;
        }
    }
    // isn't added, just add to the end
    [self addArrangedSubview:named_section_view];
}

@end
