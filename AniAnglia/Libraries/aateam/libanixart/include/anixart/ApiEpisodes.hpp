#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>

namespace anixart {
	class ApiEpisodes {
	public:
		ApiEpisodes(const ApiSession& session, const std::string& token);

		Episode::Ptr get_episode_target(const ReleaseID release_id, const EpisodeSourceID source_id, const int32_t position) const;
		std::vector<Episode::Ptr> get_release_episodes(const ReleaseID release_id, const EpisodeTypeID type_id, const EpisodeSourceID source_id, const Episode::Sort sort) const;
		std::vector<EpisodeSource::Ptr> get_release_sources(const ReleaseID release_id, const EpisodeTypeID type_id) const;
		std::vector<EpisodeType::Ptr> get_release_types(const ReleaseID release_id) const;
		std::vector<EpisodeType::Ptr> get_all_types() const;

		void add_watched_episode(const ReleaseID release_id, EpisodeSourceID source_id, const int32_t position) const;
		void add_watched(const ReleaseID release_id, EpisodeSourceID source_id) const;
		void remove_watched_episode(const ReleaseID release_id, EpisodeSourceID source_id, const int32_t position) const;
		void remove_watched(const ReleaseID release_id, EpisodeSourceID source_id) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}