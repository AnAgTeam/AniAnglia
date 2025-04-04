//
//  TimeCvt.h
//  AniAnglia
//
//  Created by Toilettrauma on 04.04.2025.
//

#ifndef TimeCvt_h
#define TimeCvt_h
#import <chrono>

template<typename T, typename U>
std::chrono::year_month_day to_utc_ymd_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::seconds utc_offset = std::chrono::seconds([[NSTimeZone localTimeZone] secondsFromGMT]);
    std::chrono::year_month_day ymd = std::chrono::floor<std::chrono::days>(time_point + utc_offset);
    return ymd;
}

template<typename T, typename U>
std::chrono::year_month_day to_gmt_ymd_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::year_month_day ymd = std::chrono::floor<std::chrono::days>(time_point);
    return ymd;
}

template<typename T, typename U>
NSString* to_utc_yy_mm_dd_string_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::year_month_day ymd = to_utc_ymd_from_gmt(time_point);
    return [NSString stringWithFormat:@"%02u.%02u.%u", static_cast<unsigned>(ymd.day()), static_cast<unsigned>(ymd.month()), static_cast<int>(ymd.year())];
}

template<typename T, typename U>
NSString* to_gmt_yy_mm_dd_string_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::year_month_day ymd = to_gmt_ymd_from_gmt(time_point);
    return [NSString stringWithFormat:@"%02u.%02u.%u", static_cast<unsigned>(ymd.day()), static_cast<unsigned>(ymd.month()), static_cast<int>(ymd.year())];
}

template<typename T, typename U>
NSString* to_utc_mm_dd_string_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::year_month_day ymd = to_utc_ymd_from_gmt(time_point);
    return [NSString stringWithFormat:@"%02u.%02u", static_cast<unsigned>(ymd.day()), static_cast<unsigned>(ymd.month())];
}

template<typename T, typename U>
NSString* to_gmt_hh_mm_string_from_gmt(std::chrono::time_point<T, U> time_point) {
    std::chrono::hh_mm_ss hhmmss { std::chrono::floor<std::chrono::milliseconds>(time_point - std::chrono::floor<std::chrono::days>(time_point)) };
    return [NSString stringWithFormat:@"%02ld:%02ld", hhmmss.hours().count(), hhmmss.minutes().count()];
}


#endif /* TimeCvt_h */
