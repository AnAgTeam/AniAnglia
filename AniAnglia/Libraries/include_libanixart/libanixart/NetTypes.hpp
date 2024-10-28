#pragma once
#include <string>
#include <vector>
#include <exception>

#pragma warning(push, 0)
#include <boost/json.hpp>
#pragma warning(pop)

namespace libanixart {

	class KeyValue {
	public:
		KeyValue(const std::string& key, const std::string& value);

		std::string key;
		std::string value;
	};

	class StaticCopyable {

	};

	class UrlParameters : public StaticCopyable {
	public:

		UrlParameters() = default;
		UrlParameters(const std::vector<KeyValue>& initial);
		UrlParameters(const UrlParameters& copy, const std::vector<KeyValue>& expanded);

		UrlParameters expand_copy(const std::vector<KeyValue>& added) const;

		std::string apply(const std::string& url) const;
		std::string get() const;
		bool empty() const;

	private:
		std::string _params;
	};

	class UrlEncoded {
	public:
		static std::string encode(const std::vector<KeyValue>& from);
	};

	using JsonObject = boost::json::object;
	using JsonArray = boost::json::array;
	using JsonError = boost::system::system_error;
	using JsonValue = boost::json::value;
	inline std::string to_string(JsonValue& val) {
		return boost::json::value_to<std::string>(val);
	}

	extern JsonObject parse_json(const std::string& from);
};

