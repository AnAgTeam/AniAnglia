#pragma once
#include <string>
#include <ext/platform.hpp>

namespace libanixart {
    extern std::string get_platform_version();
    extern void set_lib_language(std::string_view lang);
    extern std::string_view get_lib_language();
}

