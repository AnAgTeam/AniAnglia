#pragma once
#include "ApiSession.hpp"
#include "ApiTypes.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {
	class ApiCollection {
	public:
		ApiCollection(const ApiSession& session, const std::string& token);

		CollectionGetInfo::Ptr get_collection(const int64_t& collection_id);
		CollectionsPages::UniqPtr all_collections(const Collection::Sort& sort, const int32_t& where, const int32_t& start_page);
		ProfileCollectionsPages::UniqPtr profile_collections(const int64_t& profile_id, const int32_t& start_page);
		ReleaseCollectionsPages::UniqPtr release_collections(const int64_t& release_id, const Collection::Sort& sort, const int32_t& start_page);
		CollectionReleasesPages::UniqPtr collection_releases(const int64_t& collection_id, const int32_t& start_page);
		void report_collection(const int64_t& collection_id, const requests::CollectionReportRequest& request);

		void add_collection_comment(const int64_t& collection_id, const requests::CollectionCommentAddRequest& request);
		CollectionComment::Ptr get_collection_comment(const int64_t& collection_id); // wtf?
		CollectionCommentsPages::UniqPtr collection_comments(const int64_t& collection_id, const CollectionComment::Sign& sort, const int32_t& start_page);
		void remove_comment(const int64_t& comment_id);
		void edit_comment(const int64_t& comment_id, const requests::CollectionCommentEditRequest& request);
		void process_comment(const int64_t& comment_id, const requests::ReleaseCommentProcessRequest& request);
		ProfileCollectionCommentsPages::UniqPtr profile_collection_comments(const int64_t& profile_id, const ProfileCollectionCommentsPages::Sort& sort, const int32_t& start_page);
		CollectionCommentRepliesPages::UniqPtr collection_comment_replies(const int64_t& comment_id, const CollectionComment::Sign& sort, const int32_t& start_page);
		void report_collection_comment(const int64_t& comment_id, const requests::CollectionCommentReportRequest& request);
		void vote_collection_comment(const int64_t& comment_id, const CollectionComment::Sign& vote);

		void add_collection_to_favorites(const int64_t& collection_id);
		void remove_collection_from_favorites(const int64_t& collection_id);
		FavoriteCollectionsPages::UniqPtr my_favorite_collections(const int32_t& start_page);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}