#pragma once
#include <netsess/NetTypes.hpp>
#include <netsess/JsonTools.hpp>

#include <memory>
#include <string_view>
#include <concepts>
#include <vector>

#ifdef _DEBUG
#define LIBANIXART_CACHE_JSON_TYPE_CHECK
#endif

/*
TODO: edit all Caching objects to support json object references
*/

namespace anixart::json {
	class CachingJsonValue;
	class CachingJsonArray;
	class CachingJsonObject;

	struct CacheMissError : std::runtime_error {
		CacheMissError();
	};

	namespace detail {
		template<typename T>
		concept smart_pointer_with_constructible_from_caching_json_object = network::json::smart_pointer<T> && std::constructible_from<typename T::element_type, CachingJsonObject&>;
		class SharedCache;

		class CachedObject {
		public:
			CachedObject(network::JsonObject object, const std::shared_ptr<std::vector<CachedObject>>& cache);

			bool is_constructed() const;

			std::shared_ptr<void>& get_constructed();
			template<typename T>
			std::shared_ptr<T> get_constructed_as();
			template<typename T>
			std::shared_ptr<T> construct_and_add_to_cache();

		private:
			network::JsonObject _object;
			std::shared_ptr<void> _constructed_object;
			std::weak_ptr<std::vector<CachedObject>> _cache;
#ifdef LIBANIXART_CACHE_JSON_TYPE_CHECK
			const std::type_info* _constructed_object_info;
#endif
		};

		class SharedCache {
			friend class CachedObject;
		public:
			SharedCache();
			SharedCache(network::JsonValue& root_cache_value);
			SharedCache(network::JsonObject& root_cache_object);
			SharedCache(network::JsonArray& root_cache_array);
			SharedCache(const size_t initial_capacity);

			CachedObject& get_item(int64_t id);
			void add_object(const network::JsonObject& object);

		private:
			SharedCache(const std::shared_ptr<std::vector<CachedObject>>& cache);

			void traverse_and_add_to_cache(network::JsonObject& object);
			void traverse_and_add_to_cache(network::JsonArray& array);
			void traverse_and_add_to_cache(network::JsonValue& value);
			int64_t get_cached_items_count(network::JsonObject& object);
			int64_t get_cached_items_count(network::JsonArray& array);
			int64_t get_cached_items_count(network::JsonValue& value);

			network::JsonValue _root_value;
			std::shared_ptr<std::vector<CachedObject>> _cache;
		};
	};

	class CachingJsonObject {
		friend class CachingJsonValue;
		friend class detail::CachedObject;
	public:
		CachingJsonObject() = default;
		CachingJsonObject(network::JsonObject object);

		CachingJsonValue operator[](std::string_view key);
		explicit operator network::JsonObject& ();

		template<typename T>
		T get(std::string_view key);
		template<typename T>
		T get_if(std::string_view key, network::json::ParseJson::PredicateFunc&& pred);
	private:
		CachingJsonObject(network::JsonObject& object, const detail::SharedCache& cache);

		bool is_caching_object() const;
		int64_t get_cache_id();

		network::JsonObject _object;
		detail::SharedCache _shared_cache;
	};

	class CachingJsonArray {
		friend class CachingJsonValue;
	public:
		CachingJsonArray() = default;
		CachingJsonArray(network::JsonArray array);

		CachingJsonValue operator[](size_t index);
		explicit operator network::JsonArray& ();

		template<typename T>
		void assign_to(std::vector<T>& vec);
		template<typename T>
		std::vector<T> to_vector();
	private:
		CachingJsonArray(network::JsonArray& array, const detail::SharedCache& cache);

		network::JsonArray _array;
		detail::SharedCache _shared_cache;
	};

	class CachingJsonValue {
		friend class CachingJsonObject;
		friend class CachingJsonArray;
	public:
		CachingJsonValue() = default;
		CachingJsonValue(network::JsonValue value);

		bool is_null() const;

		CachingJsonObject as_object();
		CachingJsonArray as_array();
		int64_t as_int64();
		uint64_t as_uint64();
		double as_double();
		bool as_bool();

		template<typename T>
			requires requires (CachingJsonObject& a) { std::make_shared<T>(a); }
		std::shared_ptr<T> as_object_pointer();

	private:
		CachingJsonValue(network::JsonValue& value, const detail::SharedCache& cache);

		detail::CachedObject& as_cached_object();

		network::JsonValue _value;
		detail::SharedCache _shared_cache;
	};

	namespace detail {
		template<typename T>
		std::shared_ptr<T> CachedObject::get_constructed_as() {
#ifdef LIBANIXART_CACHE_JSON_TYPE_CHECK
			if (*_constructed_object_info != typeid(T)) {
				throw std::runtime_error("CachedObject: invalid type for pointer cast");
			}
#endif
			return std::static_pointer_cast<T>(get_constructed());
		}
		template<typename T>
		std::shared_ptr<T> CachedObject::construct_and_add_to_cache() {
			CachingJsonObject caching_object(_object, SharedCache(_cache.lock()));
			_constructed_object = std::make_shared<T>(caching_object);
#ifdef LIBANIXART_CACHE_JSON_TYPE_CHECK
			_constructed_object_info = &typeid(T);
#endif
			return std::static_pointer_cast<T>(get_constructed());
		}
	}

	/*
	Get object with `key` in JSON and
	1) if it's a reference in json, and object has already constructed, get it
	2) if it's a reference in json, and object hasn't already constucted, construct it and add to cache
	3) if it isn't a reference, construct from object
	*/
	template<typename T>
		requires requires (CachingJsonObject& a) { std::make_shared<T>(a); }
	std::shared_ptr<T> CachingJsonValue::as_object_pointer() {
		if (_value.is_object()) {
			CachingJsonObject object = as_object();
			if (object.is_caching_object()) {
				return _shared_cache.get_item(object.get_cache_id()).construct_and_add_to_cache<T>();
			}
			return std::make_shared<T>(object);
		}

		detail::CachedObject& cached_object = as_cached_object();
		if (cached_object.is_constructed()) {
			return cached_object.get_constructed_as<T>();
		}
		return cached_object.construct_and_add_to_cache<T>();
	}

	template<typename T>
	T CachingJsonObject::get(std::string_view key) {
		if (!_object.contains(key) || _object[key].is_null()) {
			return T{};
		}
		if constexpr (std::same_as<T, CachingJsonValue>) {
			return CachingJsonValue(_object[key], _shared_cache);
		}
		else if constexpr (std::same_as<T, CachingJsonObject>) {
			return CachingJsonValue(_object[key], _shared_cache).as_object();
		}
		else if constexpr (std::same_as<T, CachingJsonArray>) {
			return CachingJsonValue(_object[key], _shared_cache).as_array();
		}
		else if constexpr (detail::smart_pointer_with_constructible_from_caching_json_object<T>) {
			return CachingJsonValue(_object[key], _shared_cache).as_object_pointer<typename T::element_type>();
		}
		else if constexpr (std::constructible_from<T, CachingJsonObject&>) {
			CachingJsonObject object = CachingJsonValue(_object[key], _shared_cache).as_object();
			return T(object);
		}
		else {
			return network::json::ParseJson::get<T>(_object, key);
		}
	}

	template<typename T>
	T CachingJsonObject::get_if(std::string_view key, network::json::ParseJson::PredicateFunc&& pred) {
		if (!pred(_object, key)) {
			return T();
		}
		return get<T>(key);
	}

	template<typename T>
	void CachingJsonArray::assign_to(std::vector<T>& vec) {
		if (_array.size() == 0) {
			return;
		}
		vec.clear();
		vec.reserve(_array.size());
		for (auto& item : _array) {
			if constexpr (detail::smart_pointer_with_constructible_from_caching_json_object<T>) {
				CachingJsonObject object = CachingJsonValue(item, _shared_cache).as_object();
				vec.emplace_back(new T::element_type(object));
			}
			else if constexpr (std::constructible_from<T, CachingJsonObject&>) {
				CachingJsonObject object = CachingJsonValue(item, _shared_cache).as_object();
				vec.emplace_back(T(object));
			}
			else {
				vec.emplace_back(boost::json::value_to<T>(item));
			}
		}
	}

	template<typename T>
	std::vector<T> CachingJsonArray::to_vector() {
		std::vector<T> out;
		assign_to(out);
		return out;
	}
}