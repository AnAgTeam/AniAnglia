#pragma once
#include <anixart/Parser.hpp>
#include <vector>

namespace anixart::parsers {

	class Parsers {
	public:
		Parsers();

		Parser::Ptr get_parser(const std::string& url) const;
		std::unordered_map<std::string, std::string> extract_info(const std::string& url, const std::vector<ParserParameter>& params = {});

	private:
		std::vector<Parser::Ptr> _parsers;
	};
};

