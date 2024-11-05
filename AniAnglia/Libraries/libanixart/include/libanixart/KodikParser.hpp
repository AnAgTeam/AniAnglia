#pragma once
#include "ParserBase.hpp"

namespace libanixart::parsers {
	class KodikParser : public ParserBase {
	public:
		KodikParser();

		bool valid_host(const std::string& host) const override;
		std::string get_name() const override;
		std::unordered_map<std::string, std::string> extract_info_fallback(const std::string& url, const std::vector<ParserParameter>& params);
		std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params) override;

	};
}

