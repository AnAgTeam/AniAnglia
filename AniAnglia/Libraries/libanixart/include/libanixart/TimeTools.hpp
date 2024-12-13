#pragma once
#include <string>
#include <chrono>

namespace libanixart {
    class TimeTools {
    public:
        template<typename T>
        static inline T from_timestamp_tp(int64_t timestamp) {
            return T{ std::chrono::seconds(timestamp) };
        }
        static inline std::chrono::system_clock::time_point from_timestamp(int64_t timestamp) {
            return from_timestamp_tp<std::chrono::system_clock::time_point>(timestamp);
        }

        template<typename T>
        static inline int64_t to_timestamp_tp(const std::chrono::system_clock::time_point& time) {
            return std::chrono::duration_cast<T>(time.time_since_epoch()).count();
        }
        static inline int64_t to_timestamp(const std::chrono::system_clock::time_point& time) {
            return to_timestamp_tp<std::chrono::seconds>(time);
        }

    };
};