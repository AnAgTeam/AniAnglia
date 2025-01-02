#pragma once
#include "ApiAuth.hpp"
#include "ApiSearch.hpp"
#include "ApiEpisodes.hpp"
#include "ApiProfiles.hpp"
#include "ApiReleases.hpp"
#include "ApiCollection.hpp"

namespace libanixart {
	class Api {
	public:
		Api(std::string_view lang, std::string_view application);
		~Api() = default;

		const std::string& get_token() const;
		void set_token(const std::string_view token);
		void set_verbose(const bool api_verbose, const bool sess_verbose);

		const ApiSession& get_session() const;
		ApiAuth& auth();
		ApiSearch& search();
		ApiEpisodes& episodes();
		ApiProfiles& profiles();
		ApiReleases& releases();
		ApiCollection& collections();

	private:
		std::string _token;
		ApiSession _session;
		ApiAuth _auth;
		ApiSearch _search;
		ApiEpisodes _episodes;
		ApiProfiles _profiles;
		ApiReleases _releases;
		ApiCollection _collection;
	};
};
