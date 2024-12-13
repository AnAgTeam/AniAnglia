#pragma once
#include "ParserBase.hpp"

namespace libanixart::parsers {
	class LibriaParser : public ParserBase {
	public:
		LibriaParser();

		bool valid_host(const std::string& host) const override;
		std::string_view get_name() const override;
		std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params) override;

	private:

	};
};

