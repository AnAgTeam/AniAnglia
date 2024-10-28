#pragma once
#include "ParserBase.hpp"

#include <vector>

namespace libanixart::parsers {

	class Parsers {
	public:
		Parsers();

		ParserBase::Ptr get_parser(const std::string& url) const;
		std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params = {});

	private:
		std::vector<ParserBase::Ptr> _parsers;
	};
};

