#pragma once
#include <anixart/Parser.hpp>

namespace anixart::parsers {
	class KodikParser : public Parser {
	public:
		KodikParser();

		bool valid_host(const std::string& host) const override;
		std::string_view get_name() const override;
		std::unordered_map<std::string, std::string> extract_info_fallback(const std::string& url, const std::vector<ParserParameter>& params);
		std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params) override;

	private:
		int32_t get_caesar_offset(const std::string& serial_response) const;
		std::string decode_url(std::string_view encoded_url) const;

		int32_t _caesar_offset; // negative values = not valid
	};
}

