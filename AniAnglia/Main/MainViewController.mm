//
//  MainViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "AppColor.h"
#import "LibanixartApi.h"
#import "ReleaseViewController.h"
#import "StringCvt.h"
#import "ReleasesTableView.h"
#import "SearchReleasesTableView.h"
#import "ReleasesSearchHistoryView.h"

@interface NoSwipeSegmentedControl : UISegmentedControl

@end

@interface MainPageViewController : UIViewController {
    libanixart::requests::FilterRequest _filter_request;
}
@property(nonatomic) LibanixartApi* api_proxy;
@property(nonatomic, retain) ReleasesTableView* releases_table_view;

-(instancetype)initWithFilterRequest:(libanixart::requests::FilterRequest)request;

@end

@interface MainPagesViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, weak) MainViewController* main_view_controller;
@property(nonatomic) NSInteger current_page_index;
@property(nonatomic) NSInteger next_page_index;
@property(nonatomic) BOOL transition_started;
@property(nonatomic) BOOL performing_switch;
@property(nonatomic) UIViewController* should_change_to;
@property(nonatomic, retain) NSArray<MainPageViewController*>* page_view_controllers;

@end

@interface MainViewController ()
@property(nonatomic, retain) UIScrollView* pages_segment_scroll_view;
@property(nonatomic, retain) NoSwipeSegmentedControl* pages_segment_control;
@property(nonatomic, retain) MainPagesViewController* pages_view_controller;

-(void)willTransitionToPageAtIndex:(NSInteger)index;
-(void)didTransitionToPageAtIndex:(NSInteger)index completed:(BOOL)completed;
-(void)pageSegmentControlInteractionEnabled:(BOOL)interaction_enabled;

@end

@implementation NoSwipeSegmentedControl

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gesture_recognizer {
    if([gesture_recognizer isKindOfClass:UITapGestureRecognizer.class]) {
        return false;
    } else {
        return true;
    }
}

@end

@implementation MainPageViewController

-(instancetype)initWithFilterRequest:(libanixart::requests::FilterRequest)request {
    self = [super init];
    
    _api_proxy = [LibanixartApi sharedInstance];
    _filter_request = request;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}
-(void)setupView {
    _releases_table_view = [[ReleasesTableView alloc] initWithPages:_api_proxy.api->search().filter_search(_filter_request, false, 0)];
    [self.view addSubview:_releases_table_view];
    _releases_table_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_releases_table_view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_releases_table_view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_releases_table_view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_releases_table_view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    _releases_table_view.trailing_action_disabled = YES;

    [self setupLayout];
}
-(void)setupLayout {
    
}

@end

@implementation MainPagesViewController

-(instancetype)init {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _performing_switch = NO;
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer* gesture_recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    gesture_recognizer.delegate = self;
    [self.view addGestureRecognizer:gesture_recognizer];
    
    [self setupView];
}

-(void)setupView {
    _page_view_controllers = @[
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }(),
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            request.status = libanixart::Release::Status::Ongoing;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }(),
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            request.status = libanixart::Release::Status::Upcoming;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }(),
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            request.status = libanixart::Release::Status::Finished;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }(),
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            request.category = libanixart::Release::Category::Movies;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }(),
        []() -> MainPageViewController* {
            libanixart::requests::FilterRequest request;
            request.category = libanixart::Release::Category::Ova;
            return [[MainPageViewController alloc] initWithFilterRequest:request];
        }()
    ];
    
    [self setViewControllers:@[_page_view_controllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self setDataSource:self];
    [self setDelegate:self];
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(UIViewController*)pageViewController:(UIPageViewController*)page_view_controller
      viewControllerBeforeViewController:(MainPageViewController*)view_controller {
    NSInteger index = [_page_view_controllers indexOfObject:view_controller];
    if (index == NSNotFound || index <= 0) {
        return nil;
    }
    return _page_view_controllers[index - 1];
}

-(UIViewController*)pageViewController:(UIPageViewController*)page_view_controller
     viewControllerAfterViewController:(MainPageViewController*)view_controller {
    NSInteger index = [_page_view_controllers indexOfObject:view_controller];
    if (index == NSNotFound || index + 1 >= [_page_view_controllers count]) {
        return nil;
    }
    return _page_view_controllers[index + 1];
}

-(void)pageViewController:(UIPageViewController*)page_view_controller willTransitionToViewControllers:(NSArray*)pending_view_controllers {
    _transition_started = YES;
    if([pending_view_controllers count] > 0) {
        [_main_view_controller willTransitionToPageAtIndex:_current_page_index];
    }
}

-(void)pageViewController:(UIPageViewController*)page_view_controller didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray*)previous_view_controllers transitionCompleted:(BOOL)completed {
    _transition_started = NO;
    if (finished && [previous_view_controllers count] > 0) {
        self.view.userInteractionEnabled = YES;
        _current_page_index = [_page_view_controllers indexOfObject:self.viewControllers[0]];
    }
    [_main_view_controller didTransitionToPageAtIndex:_current_page_index completed:finished];
}

-(void)goToPageAtIndex:(NSInteger)index {
    NSInteger current_index = [_page_view_controllers indexOfObject:self.viewControllers[0]];
    if (current_index == index) {
        return;
    }
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (current_index > index) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    _current_page_index = index;
    /* If animation completion block don't called, then view is blocked */
    self.view.userInteractionEnabled = NO;
    _performing_switch = YES;
    
    __block __weak MainPagesViewController* weak_self = self;
    [self setViewControllers:@[_page_view_controllers[index]] direction:direction animated:YES completion:^(BOOL finished) {
        MainPagesViewController* strong_self = weak_self;
        strong_self->_performing_switch = NO;
        weak_self.view.userInteractionEnabled = YES;
        [strong_self->_main_view_controller didTransitionToPageAtIndex:index completed:YES];
    }];
}

//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
//    return self.view.userInteractionEnabled;
//}

-(BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gesture_recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)other_gesture_recognizer {
    if (![other_gesture_recognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        return YES;
    }
    if ([other_gesture_recognizer.view isKindOfClass:ReleasesTableView.class]) {
        return YES;
    }
//    NSLog(@"other:%@ (state):%ld", other_gesture_recognizer, other_gesture_recognizer.state);
    
    if(!_performing_switch && other_gesture_recognizer.state == UIGestureRecognizerStateBegan) {
        /* pan gesture began */
        [_main_view_controller willTransitionToPageAtIndex:_current_page_index];
    }
    if (other_gesture_recognizer.state == UIGestureRecognizerStateFailed || other_gesture_recognizer.state == UIGestureRecognizerStateChanged) {
        /* if 'pvc: willTransition:' don't called, then activate segment view */
        if (!_transition_started) {
            _transition_started = NO;
            [_main_view_controller didTransitionToPageAtIndex:_current_page_index completed:NO];
        }
    }
    
    if (_performing_switch && self.view.userInteractionEnabled) {
        
    }
    if (_performing_switch) {
//        [other_gesture_recognizer reset];
    }
    return NO;
}

-(void)panGesture:(UIPanGestureRecognizer*)gesture_recognizer {
    NSLog(@"panGesture:");
}


@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.inline_search_view = [ReleasesSearchHistoryView new];
    self.search_view = [SearchReleasesTableView new];
    self.hidesBarOnSwipe = NO;
    
    [self setupView];
}

-(void)setupView {
    _pages_segment_scroll_view = [UIScrollView new];
    [self.view addSubview:_pages_segment_scroll_view];
    _pages_segment_scroll_view.translatesAutoresizingMaskIntoConstraints = NO;
    [_pages_segment_scroll_view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_pages_segment_scroll_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [_pages_segment_scroll_view.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor].active = YES;
    [_pages_segment_scroll_view.heightAnchor constraintEqualToConstant:40].active = YES;
    _pages_segment_scroll_view.showsHorizontalScrollIndicator = NO;
    
    _pages_segment_control = [[NoSwipeSegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"app.main.pages_segment_control.actual.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.ongoing.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.upcoming.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.finished.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.movies.name", ""),
        NSLocalizedString(@"app.main.pages_segment_control.ova.name", "")
    ]];
    [_pages_segment_scroll_view addSubview:_pages_segment_control];
    _pages_segment_control.translatesAutoresizingMaskIntoConstraints = NO;
    [_pages_segment_control.topAnchor constraintEqualToAnchor:_pages_segment_scroll_view.topAnchor].active = YES;
    [_pages_segment_control.leadingAnchor constraintEqualToAnchor:_pages_segment_scroll_view.leadingAnchor].active = YES;
    [_pages_segment_control.widthAnchor constraintGreaterThanOrEqualToAnchor:_pages_segment_scroll_view.widthAnchor].active = YES;
    [_pages_segment_control.heightAnchor constraintEqualToAnchor:_pages_segment_scroll_view.heightAnchor].active = YES;
    _pages_segment_control.selectedSegmentIndex = 0;
//    _pages_segment_control.apportionsSegmentWidthsByContent = YES;
    [_pages_segment_control addTarget:self action:@selector(pagesSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    _pages_segment_scroll_view.contentSize = _pages_segment_control.frame.size;
    
    _pages_view_controller = [MainPagesViewController new];
    UIView* pages_view = _pages_view_controller.view;
    [self.view addSubview:pages_view];
    pages_view.translatesAutoresizingMaskIntoConstraints = NO;
    [pages_view.topAnchor constraintEqualToAnchor:_pages_segment_control.bottomAnchor constant:2].active = YES;
    [pages_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [pages_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [pages_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
    _pages_view_controller.main_view_controller = self;
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(void)pageSegmentControlInteractionEnabled:(BOOL)interaction_enabled {
    _pages_segment_control.userInteractionEnabled = interaction_enabled;
}

-(IBAction)pagesSegmentChanged:(id)sender {
    [_pages_view_controller goToPageAtIndex:_pages_segment_control.selectedSegmentIndex];
}

-(void)willTransitionToPageAtIndex:(NSInteger)index {
    self.search_bar.userInteractionEnabled = NO;
    _pages_segment_control.userInteractionEnabled = NO;
}

-(void)didTransitionToPageAtIndex:(NSInteger)index completed:(BOOL)completed {
    self.search_bar.userInteractionEnabled = YES;
    _pages_segment_control.userInteractionEnabled = YES;
    if (_pages_segment_control.selectedSegmentIndex == index) {
        return;
    }
    _pages_segment_control.selectedSegmentIndex = index;
}

@end
