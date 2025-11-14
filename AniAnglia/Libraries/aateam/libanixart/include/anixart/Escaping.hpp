#pragma once
#include <string>
#include <string_view>

namespace anixart {
	/**
	* Escape all HTML tags in string. This includes conversion like "<br>" -> '\n'
	* Note: Currently only supported tags are: "<br>"
	* @throw std::runtime_error If escape failed
	* @param str The string to escape
	* @return Escaped string
	*/
	extern std::string escape_html_text(std::string_view str);

	/**
	* Unescape all HTML tags in string. This includes conversion like '\n' -> "<br>"
	* Note: Currently only supported tags are: "<br>"
	* @throw std::runtime_error If unescape failed
	* @param str The string to unescape
	* @return Unescaped string
	*/
	extern std::string unescape_html_text(std::string_view str);
}