#pragma once
#include <netsess/NetTypes.hpp>

#include <string>
#include <vector>

namespace anixart::requests {
	class ApiGetRequest {
	public:
		std::string sub_url;
		network::UrlParameters params = network::UrlParameters();
		std::vector<std::string> headers = {};
	};
	class ApiPostRequest {
	public:
		std::string sub_url;
		network::UrlParameters params = network::UrlParameters();
		std::vector<std::string> headers = {};
		std::string data;
		std::string_view type;
	};
	class ApiPostMultipartRequest {
	public:
		std::string sub_url;
		network::UrlParameters params = network::UrlParameters();
		std::vector<std::string> headers = {};
		network::MultipartForms forms;
	};
}