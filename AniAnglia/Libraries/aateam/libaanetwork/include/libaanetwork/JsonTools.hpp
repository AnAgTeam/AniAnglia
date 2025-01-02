#pragma once
#include "NetTypes.hpp"
#include "TimeTools.hpp"

#include <string>
#include <vector>
#include <list>
#include <map>
#include <set>
#include <chrono>

#include <concepts>

/* Idea from tgbot-cpp */
namespace libnetwork::json {
    using time_point = std::chrono::system_clock::time_point;

    template<typename T>
    class Nullable;

    template<typename T, typename ... U>
    concept same_as_any_of = (std::same_as<T, U> || ...);

    template<typename T>
    concept serializable_to_json_array =
        std::is_array_v<std::remove_cvref_t<T>> ||
        std::same_as<std::remove_cvref_t<T>, std::vector<typename T::value_type>> ||
        std::same_as<std::remove_cvref_t<T>, std::list<typename T::value_type>> ||
        std::same_as<std::remove_cvref_t<T>, std::set<typename T::value_type>>;

    template<typename T>
    concept serializable_to_json_object =
        std::same_as<std::remove_cvref_t<T>, std::map<typename T::key_type, typename T::value_type, typename T::allocator_type>> ||
        std::same_as<std::remove_cvref_t<T>, std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::hasher, typename T::key_equal, typename T::allocator_type>>;

    template<typename T>
    concept enumeration = std::is_enum_v<T>;

    template<typename T>
    concept json_nullable =
        std::same_as<std::remove_cvref_t<T>, Nullable<typename T::value_type>>;

    template<typename T>
    concept smart_pointer =
        std::same_as<std::remove_cvref_t<T>, std::shared_ptr<typename T::element_type>> ||
        std::same_as<std::remove_cvref_t<T>, std::unique_ptr<typename T::element_type>>;

    template<typename T>
    class Nullable {
    public:
        static_assert(std::is_same_v<std::remove_reference_t<T>, T>, "Don't use references with Nullable<T>");
        static_assert(!json_nullable<T>, "Cannot derive Nullable<T> from Nullable<T>!");
        typedef T value_type;

        Nullable() noexcept(std::is_nothrow_default_constructible_v<T>) : _is_null(true), _value(T()) {

        }
        void set(const T& value) {
            _is_null = false;
            _value = value;
        }
        const T& get() const noexcept {
            return _value;
        }
        void clear() noexcept(std::is_nothrow_default_constructible_v<T>) {
            _is_null = true;
            _value = T();
        }
        bool is_null() const noexcept {
            return _is_null;
        }

        void operator=(const T& value) { set(value); }
    private:
        bool _is_null;
        T _value;
    };
    class InlineJson {
    public:
        static inline void open_object(std::string& json_str) {
            json_str += '{';
        }

        static inline void close_object(std::string& json_str) {
            assert(json_str.length() > 1);
            json_str[json_str.length() - 1] = '}';
        }

        static inline void open_array(std::string& json_str) {
            json_str += '[';
        }

        static inline void close_array(std::string& json_str) {
            assert(json_str.length() > 1);
            json_str[json_str.length() - 1] = ']';
        }

        template<typename T>
        static void raw_append(std::string& json_str, T&& value) {
            typedef std::remove_cvref_t<T> TNoRef;
            if constexpr (std::same_as<TNoRef, bool>) {
                json_str += value ? "true" : "false";
            }
            else if constexpr (enumeration<TNoRef>) {
                raw_append(json_str, static_cast<int32_t>(value));
            }
            else if constexpr ((std::integral<TNoRef> || std::floating_point<TNoRef>) && requires { std::to_string(value); }) {
                json_str += std::to_string(value);
            }
            else if constexpr (requires { InlineJson::serialize(value); }) {
                json_str += InlineJson::serialize(value);
            }
            else if constexpr (std::same_as<TNoRef, time_point>) {
                json_str += std::to_string(TimeTools::to_timestamp(value));
            }
            else if constexpr (same_as_any_of<TNoRef, std::string, std::string_view, char*>) {
                json_str += '"';
                json_str += value;
                json_str += '"';
            }
            else if constexpr (json_nullable<TNoRef>) {
                if (!value.is_null()) {
                    raw_append(json_str, value.get());
                }
                else {
                    json_str += "null";
                }
            }
            else {
                static_assert(!sizeof(T), "Cannot serialize T into JSON format!");
            }
        }

        template<typename T>
        static void append(std::string& json_str, std::string_view key, T&& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            raw_append(json_str, std::forward<T>(value));
            json_str += ",";
        }

        template<typename T>
        static void append(std::string& json_str, T&& value) {
            raw_append(json_str, std::forward<T>(value));
            json_str += ",";
        }

        template<serializable_to_json_array T>
        static std::string serialize(T& arr) {
            if (arr.empty()) {
                return "[]";
            }
            std::string json_str;
            open_array(json_str);
            for (auto& val : arr) {
                append(json_str, val);
            }
            close_array(json_str);
            return json_str;
        }

        template<serializable_to_json_object T>
        static std::string serialize(T& map) {
            if (map.empty()) {
                return "{}";
            }
            std::string json_str;
            open_object(json_str);
            for (auto& [key, val] : map) {
                append(json_str, key, val);
            }
            close_object(json_str);
            return json_str;
        }
    };

    class ParseJson {
    public:
        typedef bool(*PredicateFunc)(JsonObject& object, const std::string_view& key);

        static PredicateFunc DEFAULT_PRED;

        static JsonObject NULL_OBJECT;
        static JsonArray NULL_ARRAY;

        template<typename TRet>
        static TRet strong_get(JsonObject& object, const std::string_view& key) {
            return boost::json::value_to<TRet>(object[key]);

        }
        template<>
        static time_point strong_get(JsonObject& object, const std::string_view& key) {
            return TimeTools::from_timestamp(get<int64_t>(object, key));
        }
        template<>
        static JsonObject& strong_get(JsonObject& object, const std::string_view& key) {
            return object[key].as_object();

        }
        template<>
        static JsonArray& strong_get(JsonObject& object, const std::string_view& key) {
            return object[key].as_array();
        }

        template<typename TRet>
        static TRet get(JsonObject& object, const std::string_view& key) {
            return get_if<TRet>(object, key, DEFAULT_PRED);
        }
        template<typename T>
        static std::shared_ptr<T> object_get(JsonObject& object, const std::string_view& key) {
            return DEFAULT_PRED(object, key) ? std::make_shared<T>(object[key].as_object()) : nullptr;
        }
        template<typename TRet>
        static TRet get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? boost::json::value_to<TRet>(object[key]) : TRet();
        }
        template<enumeration TRet>
        static TRet get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? static_cast<TRet>(get<int32_t>(object, key)) : static_cast<TRet>(0);
        }
        template<>
        static time_point get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? TimeTools::from_timestamp(get<int64_t>(object, key)) : TimeTools::from_timestamp(0ULL);
        }
        template<>
        static JsonObject& get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? object[key].as_object() : NULL_OBJECT;
        }
        template<>
        static JsonArray& get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? object[key].as_array() : NULL_ARRAY;
        }
        template<typename T>
        static std::shared_ptr<T> object_get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            return predicate(object, key) ? std::make_shared<T>(object[key].as_object()) : nullptr;
        }

        template<typename T>
        static void assign_to_objects_array(JsonObject& object, const std::string_view& key, std::vector<T>& vec) {
            auto& json_arr = get<JsonArray&>(object, key);
            vec.reserve(json_arr.size());
            for (auto& value : json_arr) {
                if constexpr (smart_pointer<T>) {
                    vec.emplace_back(new T::element_type(value.as_object()));
                }
                else if constexpr (requires { T(value.as_object()); }) { // has constructor from JsonObject
                    vec.emplace_back(T(value.as_object()));
                }
                else {
                    vec.emplace_back(boost::json::value_to<T>(value));
                }
            }
        }
        template<typename T>
        static std::vector<std::shared_ptr<T>> get_objects_array(JsonObject& object, const std::string_view& key) {
            std::vector<std::shared_ptr<T>> out;
            auto& json_arr = get<JsonArray&>(object, key);
            out.reserve(json_arr.size());
            for (auto& value : json_arr) {
                out.push_back(std::make_shared<T>(value.as_object()));
            }
            return out;
        }

        static inline bool no_check(JsonObject& object, const std::string_view& key) {
            return true;
        }
        static inline bool exists(JsonObject& object, const std::string_view& key) {
            return object.contains(key);
        }
        static inline bool not_null(JsonObject& object, const std::string_view& key) {
            return !object[key].is_null();
        }
        static inline bool exists_not_null(JsonObject& object, const std::string_view& key) {
            return exists(object, key) && not_null(object, key);
        }
    };

/* Not really usefull. Future improvement to pre-alloc json string */
#if 0

#if defined(__GNUC__)
#define clz(x) __builtin_clz(x)
#define ctz(x) __builtin_ctz(x)
#else defined(_MSC_VER)
#define clz(x) _lzcnt_u64(x)
#define ctz(x) _tzcnt_u64(x)
#endif

    extern const uint8_t power_of_2_digits_count[65];

    /* returns >= len(x) */
    inline int calc_approx_num_length(uint64_t x) {
        size_t leading_zeros = clz(x);
        return power_of_2_digits_count[leading_zeros];
    }
    /* returns >= len(x) */
    inline int calc_approx_num_length(int64_t x) {
        size_t leading_zeros = clz(x >= 0 ? x : -x); // abs
        return power_of_2_digits_count[leading_zeros] + -(x >> 63); // add 1 if '-' at start
    }

    class InlineJsonExperimental {
    public:

        template<typename T>
        static
        std::enable_if_t<std::is_same_v<std::remove_reference_t<T>, T>, size_t>
        get_arg_size(T&& arg) {
            static_assert(false, "get_arg_size<T> not implemented!");
        }
        template<>
        static size_t get_arg_size(std::string&& arg) { return sizeof('"') + arg.length() + sizeof('"'); }
        template<>
        static size_t get_arg_size(std::string_view&& arg) { return sizeof('"') + arg.size() + sizeof('"'); }
        template<size_t _Size>
        static size_t get_arg_size(char(&&arg)[_Size]) { return _Size; }
        template<std::signed_integral T>
        static size_t get_arg_size(T&& arg) { return calc_approx_num_digits(static_cast<int64_t>(arg)); }
        template<std::unsigned_integral T>
        static size_t get_arg_size(T&& arg) { return calc_approx_num_digits(static_cast<uint64_t>(arg)); }

        template<typename T>
        static size_t get_arg_size(Nullable<T>&& arg) { return get_arg_size(std::forward<T>(arg.get())); }
        template<>
        static size_t get_arg_size(bool&& arg) { return arg ? 4ULL : 5ULL; }

        template<typename T>
        static inline void object_append(std::string&& json_str, std::string_view&& key, T&& value) {
            return object_append_object(json_str, key, value);
        }
        template<typename T>
        static inline void object_append(std::string&& json_str, std::string_view&& key, T*&& value) {
            return object_append_object(json_str, key, *value);
        }
        template<typename T>
        static void object_append_object(std::string&& json_str, std::string_view&& key, T&& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += value;
            json_str += ',';
        }
        template<typename T>
        static void object_append_number(std::string&& json_str, std::string_view&& key, T&& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += std::to_string(value);
            json_str += ',';
        }

        template<std::signed_integral T>
        inline void object_append(std::string&& json_str, std::string_view&& key, int64_t&& value) { object_append_number(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::forward<int64_t>(value)); }
        template<std::unsigned_integral T>
        inline void object_append(std::string&& json_str, std::string_view&& key, uint64_t&& value) { object_append_number(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::forward<uint64_t>(value)); }
        template<std::floating_point T>
        inline void object_append(std::string&& json_str, std::string_view&& key, double&& value) { object_append_number(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::forward<double>(value)); }

        template<>
        void object_append(std::string&& json_str, std::string_view&& key, bool&& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += value ? "true" : "false";
            json_str += ',';
        }

        template<>
        void object_append(std::string&& json_str, std::string_view&& key, std::string_view&& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":")";
            json_str += value;
            json_str += R"(",)";
        }
        template<>
        inline void object_append(std::string&& json_str, std::string_view&& key, std::string&& value) { object_append(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::string_view(value)); }
        template<>
        inline void object_append(std::string&& json_str, std::string_view&& key, char*&& value) { object_append(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::string_view(value)); }
        template<typename T>
        static void object_append(std::string&& json_str, std::string_view&& key, Nullable<T>&& value) {
            if (!value.is_null()) {
                object_append(std::forward<std::string>(json_str), std::forward<std::string_view>(key), value.get());
            }
            else {
                object_append_object(std::forward<std::string>(json_str), std::forward<std::string_view>(key), "null");
            }
        }
        template<>
        inline void object_append(std::string&& json_str, std::string_view&& key, time_point&& value) { object_append_number(std::forward<std::string>(json_str), std::forward<std::string_view>(key), TimeTools::to_timestamp(value)); }

        template<typename TLastArg>
        static size_t calc_args_size(std::string_view&& key, TLastArg&& arg) {
            return get_arg_size(std::forward<std::string_view>(key)) + sizeof(':') + get_arg_size(std::forward<TLastArg>(arg));
        }
        template<typename TArg, typename ... TOtherArgs>
        static size_t calc_args_size(std::string_view&& key, TArg&& arg, TOtherArgs&& ... other_args) {
            return get_arg_size(std::forward<std::string_view>(key)) + sizeof(':') + get_arg_size(std::forward<TArg>(arg)) + sizeof(',') + calc_args_size(std::forward<TOtherArgs>(other_args)...);
        }

        template<typename TLastArg>
        static void object_append_arg(std::string&& json_str, std::string_view&& key, TLastArg&& arg) {
            object_append(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::forward<TLastArg>(arg));
        }
        template<typename TArg, typename ... TOtherArgs>
        static void object_append_arg(std::string&& json_str, std::string_view&& key, TArg&& arg, TOtherArgs&& ... other_args) {
            object_append(std::forward<std::string>(json_str), std::forward<std::string_view>(key), std::forward<TArg>(arg));
            object_append_arg(std::forward<std::string>(json_str), std::forward<TOtherArgs>(other_args)...);
        }

        template<typename ... TOtherArgs>
        static std::string create_object(TOtherArgs&& ... other_args) {
            std::string out;
            out.reserve(sizeof('{') + calc_args_size(std::forward<TOtherArgs>(other_args)...) + sizeof('}'));
            out += '{';
            object_append_arg(std::forward<std::string>(out), std::forward<TOtherArgs>(other_args)...);
            out[out.length() - 1] = '}';
            return out;
        }

    };
#endif
};

