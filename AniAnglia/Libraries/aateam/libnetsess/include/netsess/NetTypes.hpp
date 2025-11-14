#pragma once
#include <string>
#include <vector>
#include <exception>
#include <curlpp/Form.hpp>
#pragma warning(push, 0)
#include <boost/json.hpp>
#pragma warning(pop)

namespace network {
	class UrlParameters {
	public:

		UrlParameters() = default;
		UrlParameters(UrlParameters& other) = default;
		UrlParameters(UrlParameters&& other) = default;
		UrlParameters(std::initializer_list<std::pair<std::string_view, std::string_view>> initial);
		UrlParameters(const UrlParameters& copy, std::initializer_list<std::pair<std::string_view, std::string_view>> expanded);

		UrlParameters expand_copy(std::initializer_list<std::pair<std::string_view, std::string_view>> added) const;

		UrlParameters& operator=(std::initializer_list<std::pair<std::string_view, std::string_view>> initial)&;

		std::string apply(std::string_view url) const;
		std::string get() const;
		bool empty() const;

	private:
		void append_items(std::initializer_list<std::pair<std::string_view, std::string_view>> items);

		std::string _params;
	};

	class UrlEncoded {
	public:
		/* not implemented */
		static std::string encode(std::initializer_list<std::string_view> from);

		static std::string escape(const std::string& str);
	};

	using JsonObject = boost::json::object;
	using JsonArray = boost::json::array;
	using JsonError = boost::system::system_error;
	using JsonValue = boost::json::value;
	inline std::string to_string(JsonValue& val) {
		return boost::json::value_to<std::string>(val);
	}

	extern JsonObject parse_json(std::string_view from);

	using MultipartPart = utilspp::clone_ptr<curlpp::FormPart>;
	using MultipartFilePart = curlpp::FormParts::File;
	using MultipartContentPart = curlpp::FormParts::Content;
	/* This class must contain pointer and auto delete them */
	using MultipartForms = curlpp::Forms;
};

