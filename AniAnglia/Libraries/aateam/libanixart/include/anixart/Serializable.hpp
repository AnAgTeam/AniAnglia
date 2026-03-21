#pragma once
#include <string>

namespace anixart {
	class Serializable {
	public:
		virtual ~Serializable() = default;

		virtual std::string serialize() const = 0;

	};
};