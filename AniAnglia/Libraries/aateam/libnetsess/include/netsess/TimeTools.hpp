#pragma once
#include <string>
#include <chrono>
#include <concepts>

namespace network {
    template<typename T>
    concept clock_time_point =
        std::same_as<T, std::chrono::time_point<typename T::clock, typename T::duration>>;
    template<typename T>
    concept clock_duration =
        std::same_as<T, std::chrono::duration<typename T::rep, typename T::period>>;

    class TimeTools {
    public:
        template<typename T>
            requires clock_time_point<std::remove_cvref_t<T>>
        static int64_t to_integer(T&& time) {
            return time.time_since_epoch().count();
        }
        template<typename T>
            requires clock_duration<std::remove_cvref_t<T>>
        static int64_t to_integer(T&& duration) {
            return duration.count();
        }

        template<clock_time_point T>
        static T from_integer(int64_t&& time_int) {
            return T(typename T::duration(time_int));
        }
        template<clock_duration T>
        static T from_integer(int64_t&& time_int) {
            return T(time_int);
        }
    };
};