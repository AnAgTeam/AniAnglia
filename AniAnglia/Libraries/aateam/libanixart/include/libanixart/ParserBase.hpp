#pragma once
#include <libaanetwork/UrlSession.hpp>
#include <string>
#include <vector>
#include <list>
#include <unordered_map>

namespace libanixart::parsers {
	using namespace libnetwork;

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
	class ParserBase {
	public:
		typedef std::shared_ptr<ParserBase> Ptr;

		ParserBase();

		std::list<std::string> get_default_headers() const;
		void process_params(const std::vector<ParserParameter>& params);
		template<typename ... T>
		void dbg_log(const char* fmt, T ... args) {
			if (_is_debug) printf(fmt, args...);
		}

		virtual bool valid_host(const std::string& host) const = 0;
		virtual std::string_view get_name() const = 0;
		virtual std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params) = 0;

	protected:
		UrlSession _session;
		bool _is_debug;
	};
};

