#pragma once
#include "ApiAuth.hpp"
#include "ApiSearch.hpp"
#include "ApiEpisodes.hpp"
#include "ApiProfiles.hpp"
#include "ApiReleases.hpp"

namespace libanixart {
	class Api {
	public:
		Api();
		~Api() = default;

		const std::string& get_token() const;
		void set_token(const std::string& token);
		void set_verbose(const bool& api_verbose, const bool& sess_verbose);

		const ApiSession& get_session() const;
		ApiAuth& auth();
		ApiSearch& search();
		ApiEpisodes& episodes();
		ApiProfiles& profiles();
		ApiReleases& releases();

	private:
		std::string _token;
		ApiSession _session;
		ApiAuth _auth;
		ApiSearch _search;
		ApiEpisodes _episodes;
		ApiProfiles _profiles;
		ApiReleases _releases;
	};
	/* used when language is static variable */
	extern int api_init(std::string_view lang);
	/* used when language is dynamically allocated runtime variable */
	extern int api_dyinit(const std::string& lang);
};
