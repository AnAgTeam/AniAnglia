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

@interface MainPagesViewController : UIPageViewController <UIPageViewControllerDataSource>
@property(nonatomic, retain) NSArray<MainPageViewController*>* page_view_controllers;

@end

@interface MainViewController ()
@property(nonatomic, retain) UIScrollView* pages_segment_scroll_view;
@property(nonatomic, retain) NoSwipeSegmentedControl* pages_segment_control;
@property(nonatomic, retain) MainPagesViewController* pages_view_controller;

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
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
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

-(void)goToPageAtIndex:(NSInteger)index {
    NSInteger current_index = [_page_view_controllers indexOfObject:self.viewControllers[0]];
    if (current_index == index) {
        return;
    }
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (current_index > index) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    [self setViewControllers:@[_page_view_controllers[index]] direction:direction animated:YES completion:nil];
}

//-(void)pageViewController:(UIPageViewController*)page_view_controller didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController*>*)previous_view_controllers transitionCompleted:(BOOL)completed {
//    if (!completed) {
//        return;
//    }
//}


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
    [pages_view.topAnchor constraintEqualToAnchor:_pages_segment_control.bottomAnchor].active = YES;
    [pages_view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [pages_view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [pages_view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
    
    [self setupLayout];
}

-(void)setupLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

-(IBAction)pagesSegmentChanged:(id)sender {
    [_pages_view_controller goToPageAtIndex:_pages_segment_control.selectedSegmentIndex];
}

@end
