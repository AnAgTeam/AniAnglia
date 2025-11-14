#pragma once
#include <netsess/StringTools.hpp>
#include <string>
#include <string_view>

namespace anixart::random {
	const auto ascii = network::StringTools::ASCII;

	extern std::string gen_random_string(const size_t length, std::string_view chars);
};


