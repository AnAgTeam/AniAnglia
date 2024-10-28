#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {

	class ApiSearch {
	public:
		ApiSearch(const ApiSession& session, const std::string& token);

		FilterPages filter_search(const int32_t& start_page) const;
		ReleaseSearchPages release_search(const SearchRequest& request);
		CommentsWeekPages comments_week() const;
		DiscussingPages discussing() const;
		InterestingPages interesting() const;
		RecomendationsPages recomendations(const int32_t& start_page) const;
		WatchingPages currently_watching(const int32_t& start_page) const;

		void release_vote(const int64_t& release_id, const int32_t& vote) const;
		void delete_release_vote(const int64_t& release_id) const;
		Release::Ptr random_release(const int64_t& release_id) const;
		Release::Ptr random_collection_release(const int64_t& release_id) const;
		Release::Ptr random_favority_release(const int64_t& release_id) const;
		Release::Ptr random_profile_release(const int64_t& profile_id, const int32_t& status) const;
		Release::Ptr get_release(const int64_t& release_id) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};

};

