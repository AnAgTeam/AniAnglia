#pragma once
#include <anixart/ApiAuth.hpp>
#include <anixart/ApiSearch.hpp>
#include <anixart/ApiEpisodes.hpp>
#include <anixart/ApiProfiles.hpp>
#include <anixart/ApiReleases.hpp>
#include <anixart/ApiCollection.hpp>

namespace anixart {
	class Api {
	public:
		Api(std::string_view lang, std::string_view application, std::string_view application_version);
		~Api() = default;

		const std::string& get_token() const;
		void set_token(const std::string_view token);
		void set_verbose(const bool api_verbose, const bool sess_verbose);

		ApiSession& get_session();
		const ApiSession& get_session() const;
#ifdef LIBANIXART_AUTH_PRESENTED
		ApiAuth& auth();
#endif
		ApiSearch& search();
		ApiEpisodes& episodes();
		ApiProfiles& profiles();
		ApiReleases& releases();
		ApiCollection& collections();

	private:
		std::string _token;
		ApiSession _session;
#ifdef LIBANIXART_AUTH_PRESENTED
		ApiAuth _auth;
#endif
		ApiSearch _search;
		ApiEpisodes _episodes;
		ApiProfiles _profiles;
		ApiReleases _releases;
		ApiCollection _collection;
	};
};
