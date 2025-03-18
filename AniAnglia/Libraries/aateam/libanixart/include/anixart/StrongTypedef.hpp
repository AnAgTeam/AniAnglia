#pragma once
#include <concepts>
#include <compare>
#include <string>

/*
	Slightly modified version of strong typedef from libtorrent (https://github.com/arvidn/libtorrent)
*/
namespace anixart::aux {
	template <typename Tag>
	struct difference_tag;

	template<std::integral T, typename Tag>
	struct StrongTypedef {
		using UnderlyingType = T;
		using DiffType = StrongTypedef<UnderlyingType, difference_tag<Tag>>;

		constexpr StrongTypedef(const StrongTypedef& other) noexcept = default;
		constexpr StrongTypedef(StrongTypedef&& other) noexcept = default;
		constexpr StrongTypedef() noexcept = default;
		constexpr explicit StrongTypedef(UnderlyingType val) : _val(val) {}
		constexpr explicit operator UnderlyingType() const { return _val; }
		constexpr std::strong_ordering operator<=>(const StrongTypedef& other) const noexcept {
			return _val <=> other._val;
		}
		constexpr bool operator==(const StrongTypedef& other) const noexcept {
			return _val == other._val;
		}
		StrongTypedef& operator++() {
			++_val;
			return *this;
		}
		StrongTypedef& operator--() { 
			--_val;
			return *this;
		}

		StrongTypedef operator++(int) & {
			return StrongTypedef{ _val++ };
		}
		StrongTypedef operator--(int) & {
			return StrongTypedef{ _val-- };
		}

		friend DiffType operator-(StrongTypedef lhs, StrongTypedef rhs) {
			return DiffType{ lhs._val - rhs._val };
		}
		friend StrongTypedef operator+(StrongTypedef lhs, DiffType rhs) {
			return StrongTypedef{ lhs._val + static_cast<UnderlyingType>(rhs) };
		}
		friend StrongTypedef operator+(DiffType lhs, StrongTypedef rhs) {
			return StrongTypedef{ static_cast<UnderlyingType>(lhs) + rhs._val };
		}
		friend StrongTypedef operator-(StrongTypedef lhs, DiffType rhs) {
			return StrongTypedef{ lhs._val - static_cast<UnderlyingType>(rhs) };
		}

		StrongTypedef& operator+=(DiffType rhs) & {
			_val += static_cast<UnderlyingType>(rhs);
			return *this;
		}
		StrongTypedef& operator-=(DiffType rhs) & {
			_val -= static_cast<UnderlyingType>(rhs);
			return *this;
		}

		StrongTypedef& operator=(const StrongTypedef& other) & noexcept = default;
		StrongTypedef& operator=(StrongTypedef&& other) & noexcept = default;

	private:
		UnderlyingType _val;
	};

	// meta function to return the underlying type of a StrongTypedef or enumeration
	// , or the type itself if it isn't a StrongTypedef
	template <typename T, typename = void>
	struct underlying_index { using type = T; };

	template <typename T>
		requires std::is_enum_v<T>
	struct underlying_index<T> {
		using type = typename std::underlying_type<T>::type;
	};

	template <typename T, typename Tag>
	struct underlying_index<aux::StrongTypedef<T, Tag>> { using type = T; };

	template <typename T, typename Tag>
	std::string to_string(StrongTypedef<T, Tag> const t) {
		return std::to_string(static_cast<T>(t));
	}
};