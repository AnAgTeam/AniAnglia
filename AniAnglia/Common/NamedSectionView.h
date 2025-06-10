//
//  NamedSectionView.h
//  AniAnglia
//
//  Created by Toilettrauma on 10.06.2025.
//

#ifndef NamedSectionView_h
#define NamedSectionView_h

#import <UIKit/UIKit.h>

@interface NamedSectionView : UIView

-(instancetype)initWithName:(NSString*)name view:(UIView*)view;
-(instancetype)initWithName:(NSString*)name viewController:(UIViewController*)view_controller;

-(void)setShowAllButtonEnabled:(BOOL)enabled;
-(void)setShowAllHandler:(void(^)(void))handler;

@end


#endif /* NamedSectionView_h */
