//
//  SegmentedPageViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 11.04.2025.
//

#import <Foundation/Foundation.h>
#import "SegmentedPageViewController.h"
#import "AppColor.h"

@interface NoSwipeSegmentedControl : UISegmentedControl

@end

@interface SegmentedPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, retain) UIScrollView* segments_scroll_view;
@property(nonatomic, retain) UISegmentedControl* segmented_control;
@property(nonatomic, retain) UIPageViewController* page_view_controller;
@property(nonatomic, retain) UIGestureRecognizer* page_pan_gesture_recognizer;
@property(nonatomic, retain) NSArray<UIViewController*>* page_view_controllers;
@property(nonatomic, retain) NSArray<NSString*>* segment_titles;
@property(nonatomic) NSInteger current_page_index;
@property(nonatomic) BOOL is_changing_page;

@end

@implementation NoSwipeSegmentedControl

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gesture_recognizer {
    if([gesture_recognizer isKindOfClass:UITapGestureRecognizer.class]) {
        return NO;
    } else {
        return YES;
    }
}

@end

@implementation SegmentedPageViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _segmented_control.userInteractionEnabled = YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupLayout];
}

-(void)setup {
    _segments_scroll_view = [UIScrollView new];
    _segments_scroll_view.showsHorizontalScrollIndicator = NO;
    
    if (_segment_titles) {
        _segmented_control = [[NoSwipeSegmentedControl alloc] initWithItems:_segment_titles];
    } else {
        _segmented_control = [NoSwipeSegmentedControl new];
    }
    _segmented_control.selectedSegmentIndex = 0;
    [_segmented_control addTarget:self action:@selector(onPagesSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    _page_view_controller = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _page_view_controller.dataSource = self;
    _page_view_controller.delegate = self;
    if (_page_view_controllers) {
        [_page_view_controller setViewControllers:@[_page_view_controllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    [self addChildViewController:_page_view_controller];
    
    [self.view addSubview:_segments_scroll_view];
    [_segments_scroll_view addSubview:_segmented_control];
    [self.view addSubview:_page_view_controller.view];

    _segments_scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    _segmented_control.translatesAutoresizingMaskIntoConstraints = NO;
    _page_view_controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_segments_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_segments_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_segments_scroll_view.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor],
        [_segments_scroll_view.heightAnchor constraintEqualToConstant:40],
        
        [_segmented_control.topAnchor constraintEqualToAnchor:_segments_scroll_view.topAnchor],
        [_segmented_control.leadingAnchor constraintEqualToAnchor:_segments_scroll_view.leadingAnchor],
        [_segmented_control.trailingAnchor constraintEqualToAnchor:_segments_scroll_view.trailingAnchor],
        [_segmented_control.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [_segmented_control.heightAnchor constraintEqualToAnchor:_segments_scroll_view.heightAnchor],
        
        [_page_view_controller.view.topAnchor constraintEqualToAnchor:_segments_scroll_view.bottomAnchor constant:8],
        [_page_view_controller.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [_page_view_controller.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [_page_view_controller.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
    ]];
    
    _page_pan_gesture_recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPageViewControllerPanGesture:)];
    _page_pan_gesture_recognizer.delegate = self;
    [_page_view_controller.view addGestureRecognizer:_page_pan_gesture_recognizer];
}
-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)setPageViewControllers:(NSArray<UIViewController*>*)page_view_controllers {
    _page_view_controllers = page_view_controllers;
    if (!_page_view_controller) return;
    
    if ([_page_view_controllers count] > 0) {
        [_page_view_controller setViewControllers:@[_page_view_controllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    } else {
        [_page_view_controller setViewControllers:@[] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    _page_view_controller.dataSource = nil;
    _page_view_controller.dataSource = self;
}
-(void)setSegmentTitles:(NSArray<NSString*>*)segment_titles {
    _segment_titles = segment_titles;
    if (!_segmented_control) return;
    
    [_segmented_control removeAllSegments];
    NSInteger index = 0;
    for (NSString* title : segment_titles) {
        [_segmented_control insertSegmentWithTitle:title atIndex:index++ animated:NO];
    }
}

-(IBAction)onPagesSegmentChanged:(UISegmentedControl*)sender {
    [self goToPageAtIndex:_segmented_control.selectedSegmentIndex];
}

-(void)willTransitionToPageAtIndex:(NSInteger)index {
    _segmented_control.userInteractionEnabled = NO;
}

-(void)didTransitionToPageAtIndex:(NSInteger)index completed:(BOOL)completed {
    _segmented_control.userInteractionEnabled = YES;
    if (_segmented_control.selectedSegmentIndex == index || !completed) {
        return;
    }
    _segmented_control.selectedSegmentIndex = index;
    
    CGFloat segment_width = _segmented_control.frame.size.width / _segmented_control.numberOfSegments;
    CGFloat scroll_view_width = _segments_scroll_view.frame.size.width;
    CGFloat to_scroll_x = MAX(segment_width * (index + 0.5) - scroll_view_width / 2, 0);
    CGFloat max_to_scroll_x = _segmented_control.frame.size.width - scroll_view_width;
    [_segments_scroll_view setContentOffset:CGPointMake(MIN(to_scroll_x, max_to_scroll_x), 0) animated:YES];
}

-(UIViewController*)pageViewController:(UIPageViewController*)page_view_controller
    viewControllerBeforeViewController:(UIViewController*)view_controller {
    NSInteger index = [_page_view_controllers indexOfObject:view_controller];
    if (index == NSNotFound || index <= 0) {
        return nil;
    }
    return _page_view_controllers[index - 1];
}

-(UIViewController*)pageViewController:(UIPageViewController*)page_view_controller
     viewControllerAfterViewController:(UIViewController*)view_controller {
    NSInteger index = [_page_view_controllers indexOfObject:view_controller];
    if (index == NSNotFound || index + 1 >= [_page_view_controllers count]) {
        return nil;
    }
    return _page_view_controllers[index + 1];
}

-(void)pageViewController:(UIPageViewController*)page_view_controller didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray*)previous_view_controllers transitionCompleted:(BOOL)completed {
    if (finished && completed && [previous_view_controllers count] > 0) {
        _current_page_index = [_page_view_controllers indexOfObject:_page_view_controller.viewControllers[0]];
        [self didTransitionToPageAtIndex:_current_page_index completed:completed];
    }
}

-(void)goToPageAtIndex:(NSInteger)index {
    if (_current_page_index == index || index >= [_page_view_controllers count]) {
        return;
    }
    UIPageViewControllerNavigationDirection direction = _current_page_index < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    _current_page_index = index;
    
    _page_view_controller.dataSource = nil;
    _page_view_controller.dataSource = self;
    [_page_view_controller setViewControllers:@[_page_view_controllers[index]] direction:direction animated:YES completion:nil];
}

-(BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gesture_recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)other_gesture_recognizer {
    if (![other_gesture_recognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        return NO;
    }
    return YES;
}
-(void)onPageViewControllerPanGesture:(UIPanGestureRecognizer*)gesture_recognizer {
    if (gesture_recognizer.state == UIGestureRecognizerStateBegan) {
        _segmented_control.userInteractionEnabled = NO;
    } else if (gesture_recognizer.state == UIGestureRecognizerStateEnded) {
        _segmented_control.userInteractionEnabled = YES;
    }
}

@end
