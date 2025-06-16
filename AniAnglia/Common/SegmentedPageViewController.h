//
//  SegmentedPageViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 11.04.2025.
//

#ifndef SegmentedPageViewController_h
#define SegmentedPageViewController_h

#import <UIKit/UIKit.h>

@interface SegmentedPageViewController : UIViewController

-(void)setPageViewControllers:(NSArray<UIViewController*>*)page_view_controllers;
-(void)setSegmentTitles:(NSArray<NSString*>*)segment_titles;
@end

#endif /* SegmentedPageViewController_h */
