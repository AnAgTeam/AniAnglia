#pragma once
#include "ApiSession.hpp"
#include "ApiTypes.hpp"

namespace libanixart {
	class ApiEpisodes {
	public:
		ApiEpisodes(const ApiSession& session, const std::string& token);

		Episode::Ptr get_episode_target(const int64_t& release_id, const int64_t& source_id, const int32_t& position);
		std::vector<Episode::Ptr> get_release_episodes(const int64_t& release_id, const int64_t& type_id, const int64_t& source_id, const EpisodesSort& sort);
		std::vector<EpisodeSource::Ptr> get_release_sources(const int64_t& release_id, const int64_t& type_id);
		std::vector<EpisodeType::Ptr> get_release_types(const int64_t& release_id);


	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}