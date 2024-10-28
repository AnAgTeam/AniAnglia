#pragma once
#include "NetTypes.hpp"
#include "Tools.hpp"

#include <string>
#include <vector>
#include <list>
#include <map>
#include <chrono>

/* Idea from tgbot-cpp */
namespace libanixart::json {
    template<typename T>
    class Nullable {
    public:
        Nullable() : _is_null(true), _value(T()) {

        }
        void set(const T& value) {
            _is_null = false;
            _value = value;
        }
        const T& get() const {
            return _value;
        }
        void clear() {
            _is_null = true;
            _value = T();
        }
        bool is_null() const {
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

        template<typename T>
        static inline void append(std::string& json_str, const std::string& key, const T& value) {
            return append_object(json_str, key, value);
        }
        template<typename T>
        static inline void append(std::string& json_str, const std::string& key, const T* value) {
            return append_object(json_str, key, *value);
        }
        template<typename T>
        static void append_object(std::string& json_str, const std::string& key, const T& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += value;
            json_str += ',';
        }
        template<typename T>
        static void append_number(std::string& json_str, const std::string& key, const T& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += std::to_string(value);
            json_str += ',';
        }

        template<>
        inline void append(std::string& json_str, const std::string& key, const int& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const long& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const long long& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const unsigned long& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const unsigned long long& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const short& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const unsigned short& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const float& value) { append_number(json_str, key, value); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const double& value) { append_number(json_str, key, value); }

        template<>
        void append(std::string& json_str, const std::string& key, const bool& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":)";
            json_str += value ? "true" : "false";
            json_str += ',';
        }

        template<>
        void append(std::string& json_str, const std::string& key, const std::string_view& value) {
            json_str += '"';
            json_str += key;
            json_str += R"(":")";
            json_str += value;
            json_str += R"(",)";
        }
        template<>
        inline void append(std::string& json_str, const std::string& key, const std::string& value) { append(json_str, key, std::string_view(value)); }
        template<>
        inline void append(std::string& json_str, const std::string& key, const char* value) { append(json_str, key, std::string_view(value)); }
        template<typename T>
        static void append(std::string& json_str, const std::string& key, const Nullable<T>& value) {
            if (!value.is_null()) {
                append(json_str, key, value.get());
            }
            else {
                append_object(json_str, key, "null");
            }
        }

        // ARRAYS

        static inline void close_object(std::string& json_str) {
            json_str[json_str.length() - 1] = '}';
        }


        static inline void open_array(std::string& json_str) {
            json_str += '[';
        }

        template<typename T>
        static inline void append(std::string& json_str, const T& value) {
            return append_object(json_str, value);
        }
        template<typename T>
        static inline void append(std::string& json_str, const T* value) {
            return append_object(json_str, *value);
        }
        template<typename T>
        static void append_object(std::string& json_str, const T& value) {
            json_str += value;
            json_str += ',';
        }
        template<typename T>
        static void append_number(std::string& json_str, const T& value) {
            json_str += std::to_string(value);
            json_str += ',';
        }

        template<>
        inline void append(std::string& json_str, const int& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const long& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const long long& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const unsigned long& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const unsigned long long& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const short& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const unsigned short& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const float& value) { append_number(json_str, value); }
        template<>
        inline void append(std::string& json_str, const double& value) { append_number(json_str, value); }

        template<>
        inline void append(std::string& json_str, const bool& value) {
            json_str += value ? "true" : "false";
            json_str += ',';
        }

        template<>
        inline void append(std::string& json_str, const std::string_view& value) {
            json_str += '"';
            json_str += value;
            json_str += R"(",)";
        }
        template<>
        inline void append(std::string& json_str, const std::string& value) { append(json_str, std::string_view(value)); }
        template<>
        inline void append(std::string& json_str, const char* value) { append(json_str, std::string_view(value)); }

        static inline void close_array(std::string& json_str) {
            json_str[json_str.length() - 1] = ']';
        }

        template<typename T>
        static std::string serialize_array(T& arr) {
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

        template<typename T>
        static std::string serialize(const std::vector<T>& arr) { return serialize_array(arr); }
        template<typename T>
        static std::string serialize(const std::list<T>& arr) { return serialize_array(arr); }

        template<typename T>
        static std::string serialize_map(T& map) {
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

        template<typename TKey, typename TVal>
        static std::string serialize(const std::map<TKey, TVal>& map) { return serialize_map(map); }
        template<typename TKey, typename TVal>
        static std::string serialize(const std::unordered_map<TKey, TVal>& map) { return serialize_map(map); }
    };

    class ParseJson {
    public:
        using time_point = std::chrono::system_clock::time_point;
        typedef bool(*PredicateFunc)(JsonObject& object, const std::string_view& key);

        static JsonObject NULL_OBJECT;
        static JsonArray NULL_ARRAY;

        template<typename TRet>
        static TRet get(JsonObject& object, const std::string_view& key) {
            return boost::json::value_to<TRet>(object[key]);
        }
        template<>
        static time_point get(JsonObject& object, const std::string_view& key) {
            return TimeTools::from_timestamp(get<int64_t>(object, key));
        }
        template<>
        static JsonObject& get(JsonObject& object, const std::string_view& key) {
            return object[key].as_object();
        }
        template<>
        static JsonArray& get(JsonObject& object, const std::string_view& key) {
            return object[key].as_array();
        }
        template<typename T>
        static std::shared_ptr<T> object_get(JsonObject& object, const std::string_view& key) {
            return std::make_shared<T>(object[key].as_object());
        }
        template<typename TRet>
        static TRet get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            if (predicate(object, key)) {
                return boost::json::value_to<TRet>(object[key]);
            }
            else {
                return TRet();
            }
        }
        template<>
        static time_point get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            if (predicate(object, key)) {
                return TimeTools::from_timestamp(get<int64_t>(object, key));
            }
            else {
                return TimeTools::from_timestamp(0ULL);
            }
        }
        template<>
        static JsonObject& get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            if (predicate(object, key)) {
                return object[key].as_object();
            }
            else {
                return NULL_OBJECT;
            }
        }
        template<>
        static JsonArray& get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            if (predicate(object, key)) {
                return object[key].as_array();
            }
            else {
                return NULL_ARRAY;
            }
        }
        template<typename T>
        static std::shared_ptr<T> object_get_if(JsonObject& object, const std::string_view& key, PredicateFunc predicate) {
            if (predicate(object, key)) {
                return std::make_shared<T>(object[key].as_object());
            }
            else {
                return nullptr;
            }
        }

        template<typename T>
        static void assign_to_objects_array(JsonObject& object, const std::string_view& key, std::vector<std::shared_ptr<T>>& vec) {
            auto& json_arr = get<JsonArray&>(object, key);
            vec.reserve(json_arr.size());
            for (auto& value : json_arr) {
                vec.push_back(std::make_shared<T>(value.as_object()));
            }
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
};

