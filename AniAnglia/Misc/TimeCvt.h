//
//  TimeCvt.h
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#ifndef TimeCvt_h
#define TimeCvt_h

#import <UIKit/UIKit.h>
#import <chrono>

template<typename Clock, typename Duration>
NSDate* anix_time_point_to_nsdate(std::chrono::time_point<Clock, Duration> time_point) {
    const auto duration_epoch = std::chrono::floor<std::chrono::milliseconds>(time_point.time_since_epoch()) - std::chrono::hours(3);
    const double secs = duration_epoch.count() / 1000.;
    return [NSDate dateWithTimeIntervalSince1970:secs];
}

#endif /* TimeCvt_h */
