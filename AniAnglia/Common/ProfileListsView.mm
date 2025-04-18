//
//  ProfileListsView.m
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#import <Foundation/Foundation.h>
#import "ProfileListsView.h"
#import "LibanixartApi.h"
#import "AppColor.h"

@interface ProfileListLegendView ()
@property(nonatomic, retain, readonly) NSString* legend_name;
@property(nonatomic, retain, readonly) UIColor* legend_color;
@property(nonatomic, readonly) NSInteger legend_count;
@property(nonatomic, retain) UIView* legend_color_view;
@property(nonatomic, retain) UILabel* legend_name_label;
@property(nonatomic, retain) UILabel* legend_count_label;

-(instancetype)initWithLegendName:(NSString*)name color:(UIColor*)color count:(NSInteger)count;

-(void)setCount:(NSInteger)count;
@end

@interface ProfileListsView () {
    int32_t _watching_count;
    int32_t _plan_count;
    int32_t _watched_count;
    int32_t _holdon_count;
    int32_t _dropped_count;
}
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) UILabel* me_label;
@property(nonatomic, retain) UIView* total_indicator_view;
@property(nonatomic, retain) UIView* watching_indicator_view;
@property(nonatomic, retain) UIView* plan_indicator_view;
@property(nonatomic, retain) UIView* watched_indicator_view;
@property(nonatomic, retain) UIView* holdon_indicator_view;
@property(nonatomic, retain) UIView* dropped_indicator_view;
@property(nonatomic, retain) ProfileListLegendView* watching_legend_view;
@property(nonatomic, retain) ProfileListLegendView* plan_legend_view;
@property(nonatomic, retain) ProfileListLegendView* watched_legend_view;
@property(nonatomic, retain) ProfileListLegendView* holdon_legend_view;
@property(nonatomic, retain) ProfileListLegendView* dropped_legend_view;
@property(nonatomic, retain) NSArray<NSLayoutConstraint*>* indicator_constraints;

@end

@implementation ProfileListLegendView

-(instancetype)initWithLegendName:(NSString*)name color:(UIColor*)color count:(NSInteger)count {
    self = [super init];
    
    _legend_name = name;
    _legend_color = color;
    _legend_count = count;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(void)setup {
    _legend_color_view = [UIView new];
    _legend_color_view.layer.cornerRadius = 5;
    
    _legend_name_label = [UILabel new];
    _legend_name_label.text = _legend_name;
    _legend_name_label.textAlignment = NSTextAlignmentLeft;
    
    _legend_count_label = [UILabel new];
    _legend_count_label.text = [@(_legend_count) stringValue];
    _legend_count_label.textAlignment = NSTextAlignmentRight;
    _legend_count_label.numberOfLines = 1;
    
    [self addSubview:_legend_color_view];
    [self addSubview:_legend_name_label];
    [self addSubview:_legend_count_label];
    
    _legend_color_view.translatesAutoresizingMaskIntoConstraints = NO;
    _legend_name_label.translatesAutoresizingMaskIntoConstraints = NO;
    _legend_count_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_legend_color_view.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [_legend_color_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_legend_color_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_legend_color_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        
        // TODO: change constraints
        [_legend_name_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_legend_name_label.leadingAnchor constraintEqualToAnchor:_legend_color_view.trailingAnchor constant:5],
        [_legend_name_label.trailingAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_legend_name_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
        
        [_legend_count_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_legend_count_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_legend_color_view.trailingAnchor constant:5],
//        [_legend_count_label.leadingAnchor constraintGreaterThanOrEqualToAnchor:_legend_name_label.trailingAnchor constant:5],
        [_legend_count_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_legend_count_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor]
    ]];
    [_legend_name_label sizeToFit];
    [_legend_count_label sizeToFit];
}
-(void)setupLayout {
    _legend_color_view.backgroundColor = _legend_color;
    _legend_name_label.textColor = [AppColorProvider textSecondaryColor];
    _legend_count_label.textColor = [AppColorProvider textColor];
}

-(void)setCount:(NSInteger)count {
    _legend_count_label.text = [@(count) stringValue];
    [_legend_count_label sizeToFit];
}

@end

@implementation ProfileListsView

-(instancetype)initWithReleaseInfo:(anixart::Release::Ptr)release name:(NSString*)name {
    self = [super init];
    
    _watching_count = release->watching_count;
    _plan_count = release->plan_count;
    _watched_count = release->watched_count;
    _holdon_count = release->hold_on_count;
    _dropped_count = release->dropped_count;
    _name = name;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(instancetype)initWithProfile:(anixart::Profile::Ptr)profile name:(NSString*)name {
    self = [super init];
    
    _watching_count = profile->watching_count;
    _plan_count = profile->plan_count;
    _watched_count = profile->watched_count;
    _holdon_count = profile->hold_on_count;
    _dropped_count = profile->dropped_count;
    _name = name;
    [self setup];
    [self setupLayout];
    
    return self;
}
-(instancetype)initWithCollectionGetInfo:(anixart::CollectionGetInfo::Ptr)collection_get_info name:(NSString*)name {
    self = [super init];
    
    _watching_count = collection_get_info->watching_count;
    _plan_count = collection_get_info->plan_count;
    _watched_count = collection_get_info->completed_count;
    _holdon_count = collection_get_info->hold_on_count;
    _dropped_count = collection_get_info->dropped_count;
    _name = name;
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _me_label = [UILabel new];
    _me_label.text = _name;
    _me_label.font = [UIFont systemFontOfSize:22];
    _total_indicator_view = [UIView new];
    _total_indicator_view.layer.cornerRadius = 5;
    _total_indicator_view.clipsToBounds = YES;
    _watching_indicator_view = [UIView new];
    _plan_indicator_view = [UIView new];
    _watched_indicator_view = [UIView new];
    _holdon_indicator_view = [UIView new];
    _dropped_indicator_view = [UIView new];
    
    _watching_legend_view = [[ProfileListLegendView alloc] initWithLegendName:NSLocalizedString(@"app.profile.list_status.watching.name", "") color:[UIColor systemIndigoColor] count:_watching_count];
    _plan_legend_view = [[ProfileListLegendView alloc] initWithLegendName:NSLocalizedString(@"app.profile.list_status.plan.name", "") color:[UIColor systemYellowColor] count:_plan_count];
    _watched_legend_view = [[ProfileListLegendView alloc] initWithLegendName:NSLocalizedString(@"app.profile.list_status.watched.name", "") color:[UIColor systemGreenColor] count:_watched_count];
    _holdon_legend_view = [[ProfileListLegendView alloc] initWithLegendName:NSLocalizedString(@"app.profile.list_status.holdon.name", "") color:[UIColor systemPurpleColor] count:_holdon_count];
    _dropped_legend_view = [[ProfileListLegendView alloc] initWithLegendName:NSLocalizedString(@"app.profile.list_status.dropped.name", "") color:[UIColor systemRedColor] count:_dropped_count];
    double total_lists_count = _watching_count + _plan_count + _watched_count + _holdon_count + _dropped_count;
    
    [self addSubview:_me_label];
    [self addSubview:_watching_indicator_view];
    [self addSubview:_total_indicator_view];
    [_total_indicator_view addSubview:_watching_indicator_view];
    [_total_indicator_view addSubview:_plan_indicator_view];
    [_total_indicator_view addSubview:_watched_indicator_view];
    [_total_indicator_view addSubview:_holdon_indicator_view];
    [_total_indicator_view addSubview:_dropped_indicator_view];
    [self addSubview:_watching_legend_view];
    [self addSubview:_plan_legend_view];
    [self addSubview:_watched_legend_view];
    [self addSubview:_holdon_legend_view];
    [self addSubview:_dropped_legend_view];
    
    _me_label.translatesAutoresizingMaskIntoConstraints = NO;
    _total_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watching_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watched_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _plan_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _holdon_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _dropped_indicator_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watching_legend_view.translatesAutoresizingMaskIntoConstraints = NO;
    _plan_legend_view.translatesAutoresizingMaskIntoConstraints = NO;
    _watched_legend_view.translatesAutoresizingMaskIntoConstraints = NO;
    _holdon_legend_view.translatesAutoresizingMaskIntoConstraints = NO;
    _dropped_legend_view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_me_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_me_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_me_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_total_indicator_view.topAnchor constraintEqualToAnchor:_me_label.bottomAnchor constant:5],
        [_total_indicator_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor constant:5],
        [_total_indicator_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor constant:-5],
        [_total_indicator_view.heightAnchor constraintEqualToConstant:20],
        
        [_watching_indicator_view.topAnchor constraintEqualToAnchor:_total_indicator_view.topAnchor],
        [_watching_indicator_view.leadingAnchor constraintEqualToAnchor:_total_indicator_view.leadingAnchor],
        [_watching_indicator_view.heightAnchor constraintEqualToAnchor:_total_indicator_view.heightAnchor],
        
        [_plan_indicator_view.topAnchor constraintEqualToAnchor:_total_indicator_view.topAnchor],
        [_plan_indicator_view.leadingAnchor constraintEqualToAnchor:_watching_indicator_view.trailingAnchor],
        [_plan_indicator_view.heightAnchor constraintEqualToAnchor:_total_indicator_view.heightAnchor],
        
        [_watched_indicator_view.topAnchor constraintEqualToAnchor:_total_indicator_view.topAnchor],
        [_watched_indicator_view.leadingAnchor constraintEqualToAnchor:_plan_indicator_view.trailingAnchor],
        [_watched_indicator_view.heightAnchor constraintEqualToAnchor:_total_indicator_view.heightAnchor],
        
        [_holdon_indicator_view.topAnchor constraintEqualToAnchor:_total_indicator_view.topAnchor],
        [_holdon_indicator_view.leadingAnchor constraintEqualToAnchor:_watched_indicator_view.trailingAnchor],
        [_holdon_indicator_view.heightAnchor constraintEqualToAnchor:_total_indicator_view.heightAnchor],
        
        [_dropped_indicator_view.topAnchor constraintEqualToAnchor:_total_indicator_view.topAnchor],
        [_dropped_indicator_view.leadingAnchor constraintEqualToAnchor:_holdon_indicator_view.trailingAnchor],
        [_dropped_indicator_view.trailingAnchor constraintLessThanOrEqualToAnchor:_total_indicator_view.trailingAnchor],
        [_dropped_indicator_view.heightAnchor constraintEqualToAnchor:_total_indicator_view.heightAnchor],
        
        [_watching_legend_view.topAnchor constraintEqualToAnchor:_total_indicator_view.bottomAnchor constant:5],
        [_watching_legend_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_watching_legend_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor constant:-5],
        [_watching_legend_view.heightAnchor constraintEqualToConstant:40],
        
        [_plan_legend_view.topAnchor constraintEqualToAnchor:_total_indicator_view.bottomAnchor constant:5],
        [_plan_legend_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor constant:5],
        [_plan_legend_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_plan_legend_view.heightAnchor constraintEqualToConstant:40],
        
        [_watched_legend_view.topAnchor constraintEqualToAnchor:_watching_legend_view.bottomAnchor constant:5],
        [_watched_legend_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_watched_legend_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor constant:-5],
        [_watched_legend_view.heightAnchor constraintEqualToConstant:40],
        
        [_holdon_legend_view.topAnchor constraintEqualToAnchor:_plan_legend_view.bottomAnchor constant:5],
        [_holdon_legend_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor constant:5],
        [_holdon_legend_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [_holdon_legend_view.heightAnchor constraintEqualToConstant:40],
        
        [_dropped_legend_view.topAnchor constraintEqualToAnchor:_watched_legend_view.bottomAnchor constant:5],
        [_dropped_legend_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_dropped_legend_view.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor constant:-5],
        [_dropped_legend_view.heightAnchor constraintEqualToConstant:40],
        [_dropped_legend_view.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
    ]];
    if (total_lists_count != 0) {
        _indicator_constraints = @[
            [_watching_indicator_view.widthAnchor constraintLessThanOrEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_watching_count / total_lists_count)],
            [_plan_indicator_view.widthAnchor constraintLessThanOrEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_plan_count / total_lists_count)],
            [_watched_indicator_view.widthAnchor constraintLessThanOrEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_watched_count / total_lists_count)],
            [_holdon_indicator_view.widthAnchor constraintLessThanOrEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_holdon_count / total_lists_count)],
            [_dropped_indicator_view.trailingAnchor constraintEqualToAnchor:_total_indicator_view.trailingAnchor]
        ];
        [NSLayoutConstraint activateConstraints:_indicator_constraints];
    }
    [_me_label sizeToFit];
}
-(void)setupLayout {
    _total_indicator_view.backgroundColor = [AppColorProvider foregroundColor1];
    _watching_indicator_view.backgroundColor = [UIColor systemIndigoColor];
    _plan_indicator_view.backgroundColor = [UIColor systemYellowColor];
    _watched_indicator_view.backgroundColor = [UIColor systemGreenColor];
    _holdon_indicator_view.backgroundColor = [UIColor systemPurpleColor];
    _dropped_indicator_view.backgroundColor = [UIColor systemRedColor];
}

-(void)updateIndicators {
    double total_lists_count = _watching_count + _plan_count + _watched_count + _holdon_count + _dropped_count;
    
    if (_indicator_constraints) {
        [NSLayoutConstraint deactivateConstraints:_indicator_constraints];
    }
    if (total_lists_count != 0) {
        _indicator_constraints = @[
            [_watching_indicator_view.widthAnchor constraintEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_watching_count / total_lists_count)],
            [_plan_indicator_view.widthAnchor constraintEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_plan_count / total_lists_count)],
            [_watched_indicator_view.widthAnchor constraintEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_watched_count / total_lists_count)],
            [_holdon_indicator_view.widthAnchor constraintEqualToAnchor:_total_indicator_view.widthAnchor multiplier:(_holdon_count / total_lists_count)],
            [_dropped_indicator_view.trailingAnchor constraintEqualToAnchor:_total_indicator_view.trailingAnchor]
        ];
        [NSLayoutConstraint activateConstraints:_indicator_constraints];
    }
    
    [_watching_legend_view setCount:_watching_count];
    [_plan_legend_view setCount:_plan_count];
    [_watched_legend_view setCount:_watched_count];
    [_holdon_legend_view setCount:_holdon_count];
    [_dropped_legend_view setCount:_dropped_count];
}

-(void)setReleaseInfo:(anixart::Release::Ptr)release {
    _watching_count = release->watching_count;
    _plan_count = release->plan_count;
    _watched_count = release->watched_count;
    _holdon_count = release->hold_on_count;
    _dropped_count = release->dropped_count;
    [self updateIndicators];
}
-(void)setProfile:(anixart::Profile::Ptr)profile {
    _watching_count = profile->watching_count;
    _plan_count = profile->plan_count;
    _watched_count = profile->watched_count;
    _holdon_count = profile->hold_on_count;
    _dropped_count = profile->dropped_count;
    [self updateIndicators];
}
@end
