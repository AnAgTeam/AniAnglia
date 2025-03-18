#pragma once
#include <stdexcept>

namespace torrentrepo {
	struct RuntimeError : public std::runtime_error {
		using std::runtime_error::runtime_error;
		using std::runtime_error::what;
	};
	struct LogicError : public std::logic_error {
		using std::logic_error::logic_error;
	};
}