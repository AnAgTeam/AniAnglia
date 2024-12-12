#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {
	class ApiSearch {
	public:
		ApiSearch(const ApiSession& session, const std::string& token);

		FilterPages::UniqPtr filter_search(const requests::FilterRequest& filter_request, const bool& extended_mode, const int32_t& start_page) const;
		ReleaseSearchPages::UniqPtr release_search(const requests::SearchRequest& request) const;
		CommentsWeekPages::UniqPtr comments_week() const;
		DiscussingPages::UniqPtr discussing() const;
		InterestingPages::UniqPtr interesting() const;
		RecomendationsPages::UniqPtr recomendations(const int32_t& start_page) const;
		WatchingPages::UniqPtr currently_watching(const int32_t& start_page) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};

};

