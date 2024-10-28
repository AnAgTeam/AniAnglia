#pragma once
#include "NetTypes.hpp"

#include <list>
#include <vector>
#include <string>
#include <curlpp/cURLpp.hpp>
#include <curlpp/Easy.hpp>

namespace libanixart {

	class UrlSessionError : public std::exception {
	public:
		const char* what() const noexcept override;
	};

	using MultipartPart = utilspp::clone_ptr<curlpp::FormPart>;
	using MultipartFilePart = curlpp::FormParts::File;
	using MultipartContentPart = curlpp::FormParts::Content;
	using MultipartForms = curlpp::Forms;

	class UrlSession {
	public:
		static const std::string_view COOKIEFILE_MEMORY;

		static void init();
		static void deinit();

		UrlSession();
		virtual ~UrlSession();

		void enable_redirects(const bool& value, const long& max);
		void set_verbose(const bool& value);
		void set_timeout(const long& value);
		void set_default_headers(const std::list<std::string>& headers);
		void add_default_header(const std::string& header);
		void set_cookie_file(const std::string& filename);

		std::string get_request(const std::string& url, const std::vector<std::string>& extra_headers = {}, const UrlParameters& params = UrlParameters()) const;
		std::string post_request(const std::string& url, const std::string& data, const std::string& content_type, const std::vector<std::string>& extra_headers = {}, const UrlParameters& params = UrlParameters()) const;
		/* forms have to be valid until request */
		std::string post_multipart_request(const std::string& url, const MultipartForms& forms, const UrlParameters& params = UrlParameters()) const;

	private:
		curlpp::Easy _easy_handle;
		std::list<std::string> _default_headers;
	};

}

