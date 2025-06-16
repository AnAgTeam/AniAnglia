#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiPageableRequests.hpp>

namespace anixart {
	class ApiSearch {
	public:
		ApiSearch(const ApiSession& session, const std::string& token);

		FilterPages::UPtr filter_search(const requests::FilterRequest& filter_request, const bool extended_mode, const int32_t start_page) const;
		ReleaseSearchPages::UPtr release_search(const requests::SearchRequest& request, const int32_t start_page) const;
		ProfileSearchPages::UPtr profile_search(const requests::SearchRequest& request, const int32_t start_page) const;
		ProfileListSearchPages::UPtr profile_list_search(const Profile::ListStatus list_status, const requests::SearchRequest& request, const int32_t start_page) const;
		ProfileCollectionSearchPages::UPtr profile_collection_search(const ProfileID profile_id, const ReleaseID release_id, const requests::SearchRequest& request, const int32_t start_page) const;
		CollectionSearchPages::UPtr collection_search(const requests::SearchRequest& request, const int32_t start_page) const;
		FavoriteCollectionSearchPages::UPtr favorite_collection_search(const requests::SearchRequest& request, const int32_t start_page) const;
		FavoriteSearchPages::UPtr favorite_search(const requests::SearchRequest& request, const int32_t start_page) const;
		HistorySearchPages::UPtr history_search(const requests::SearchRequest& request, const int32_t start_page) const;

		CommentsWeekPages::UPtr comments_week() const;
		DiscussingPages::UPtr discussing() const;
		InterestingPages::UPtr interesting() const;
		RecomendationsPages::UPtr recomendations(const int32_t start_page) const;
		WatchingPages::UPtr currently_watching(const int32_t start_page) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};

};

