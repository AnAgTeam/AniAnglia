#pragma once
#include "NetTypes.hpp"
#include "ApiRequests.hpp"

#include <libaanetwork/UrlSession.hpp>

namespace libanixart {
	class ApiSession : public UrlSession {
	public:
		ApiSession(std::string_view lang, std::string_view application);
		virtual ~ApiSession() = default;

		void set_verbose(const bool api_verbose, const bool sess_verbose);

		JsonObject api_request(const ApiPostRequest& request) const;
		JsonObject api_request(const ApiGetRequest& request) const;
		JsonObject api_request(const ApiPostMultipartRequest& request) const;

	private:
		bool _is_verbose;
	};
};
