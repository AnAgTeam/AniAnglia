#pragma once
#include <boost/variant.hpp>
#include <boost/mpl/distance.hpp>
#include <boost/mpl/begin.hpp>
#include <boost/mpl/find.hpp>

namespace anixart {
	template<typename ... T>
	using Variant = boost::variant<T...>;

    /* https://stackoverflow.com/questions/27045453/how-do-i-get-the-which-of-a-particular-type-in-a-boostvariant */
    template <typename Variant, typename Which>
    constexpr int variant_magic() {
        size_t pos = boost::mpl::distance
            <typename boost::mpl::begin<typename Variant::types>::type,
            typename boost::mpl::find<typename Variant::types, Which>::type
            >::type::value;

        size_t last = boost::mpl::distance
            <typename boost::mpl::begin<typename Variant::types>::type,
            typename boost::mpl::end<typename Variant::types>::type
            >::type::value;

        size_t return_index = pos != last ? pos : -1;
        //static_assert(return_index <= INT_MAX);
        return static_cast<int>(return_index);
    }

    template<typename Value, typename Variant>
    decltype(auto) variant_get(Variant&& variant) {
        return boost::get<Value>(std::forward<Variant>(variant));
    }
}