#pragma once
#include <concepts>
#include <memory>

namespace network {
	template<typename T, typename ... U>
	concept same_as_any_of = (std::same_as<T, U> || ...);

	template<typename T>
	concept enumeration = std::is_enum_v<T>;

	template<typename T>
	concept smart_pointer =
		std::same_as<T, std::shared_ptr<typename T::element_type>> ||
		std::same_as<T, std::unique_ptr<typename T::element_type>>;
};