#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {
	class ApiSearch {
	public:
		ApiSearch(const ApiSession& session, const std::string& token);

		FilterPages filter_search(const requests::FilterRequest& filter_request, const int32_t& start_page) const;
		ReleaseSearchPages release_search(const requests::SearchRequest& request) const;
		CommentsWeekPages comments_week() const;
		DiscussingPages discussing() const;
		InterestingPages interesting() const;
		RecomendationsPages recomendations(const int32_t& start_page) const;
		WatchingPages currently_watching(const int32_t& start_page) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};

};

