#pragma once
#include <anixart/ApiRequests.hpp>
#include <netsess/NetTypes.hpp>
#include <netsess/UrlSession.hpp>

namespace anixart {
	class ApiSession : public network::UrlSession {
	public:
		ApiSession(std::string_view lang, std::string_view application, std::string_view application_version);
		virtual ~ApiSession() = default;

		void set_verbose(const bool api_verbose, const bool sess_verbose);
		void switch_base_url(bool is_alt);

		network::JsonObject api_request(const ApiPostRequest& request) const;
		network::JsonObject api_request(const ApiGetRequest& request) const;
		network::JsonObject api_request(const ApiPostMultipartRequest& request) const;

	private:
		bool _is_verbose;
		std::string _base_url;
	};
};
