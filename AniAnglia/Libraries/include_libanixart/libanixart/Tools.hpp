#pragma once
#include <string>
#include <stdarg.h>
#include <chrono>

#if defined(__APPLE__) && defined(__MACH__)
# include <TargetConditionals.h>
#endif

namespace libanixart {

    class StringTools {
    public:
        static const std::string_view ASCII;

        static std::string gen_random_string(size_t length, std::string_view chars);

        static std::string vsnformat(const std::string_view format, va_list args) {
# if TARGET_IPHONE_SIMULATOR == 1
            va_list vargs1;
            va_copy(vargs1, args);
            const int size_s = std::vsnprintf(nullptr, 0, format.data(), vargs1);
#else
            const int size_s = std::vsnprintf(nullptr, 0, format.data(), args);
# endif
            

            if (size_s <= 0) {
                return {};
            }

            const size_t size = static_cast<size_t>(size_s);
            //std::string buf;
            //buf._Resize_and_overwrite(size, [&](char* buf, size_t buf_size) {
            //    return std::snprintf(buf, buf_size + 1, format.data(), format_forward<std::remove_reference_t<_Args>>(args)...);
            //});
            std::string buf(size, 0);
            std::vsnprintf(buf.data(), size + 1, format.data(), args);

            return buf;
        }
        static std::string snformat(const std::string_view format, ...) {
            va_list vargs;
            va_start(vargs, format);
            std::string ret = vsnformat(format, vargs);
            va_end(vargs);
            return ret;
        }
        template<typename ... TArgs>
        static std::string sformat(const std::string_view format, const TArgs& ... args) {
            return snformat(format, args.c_str()...);
        }
    };

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

    extern std::string get_platform_version();
    extern void set_lib_language(std::string_view lang);
    extern std::string_view get_lib_language();

};