#pragma once
#include <string>
#include <stdarg.h>

#if defined(__APPLE__) && defined(__MACH__)
# include <TargetConditionals.h>
#endif


namespace libnetwork {
    template<typename T>
    concept stringlike = std::same_as<std::remove_cvref_t<T>, std::string> || std::same_as<std::remove_cvref_t<T>, std::string_view>;

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

        template<stringlike ... TArgs>
        static std::string sformat(const std::string_view format, const TArgs& ... args) {
            return snformat(format, args.data()...);
        }
    };
};
