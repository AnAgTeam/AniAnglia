#pragma once
#include <netsess/UrlSession.hpp>
#include <string>
#include <vector>
#include <list>
#include <unordered_map>

namespace anixart::parsers {
	enum class ParserParameterType {
		Unknown = 0,
		CustomHeader,
		Debug,
		NoFallback
	};
	struct ParserParameter {
		ParserParameterType id;
		std::string value;
	};
	class Parser {
	public:
		typedef std::shared_ptr<Parser> Ptr;

	protected:
		Parser();

		std::list<std::string> get_default_headers() const;
		void process_params(const std::vector<ParserParameter>& params);
		template<typename ... T>
		void dbg_log(const char* fmt, T ... args) {
			if (_is_debug) printf(fmt, args...);
		}

	public:
		virtual bool valid_host(const std::string& host) const = 0;
		virtual std::string_view get_name() const = 0;
		virtual std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params) = 0;

	protected:
		network::UrlSession _session;
		bool _is_debug;
	};
};

