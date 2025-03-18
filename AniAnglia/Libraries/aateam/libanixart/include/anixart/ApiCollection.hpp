#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>
#include <anixart/ApiPageableRequests.hpp>

namespace anixart {
	class ApiCollection {
	public:
		ApiCollection(const ApiSession& session, const std::string& token);

		CollectionGetInfo::Ptr get_collection(const CollectionID collection_id);
		CollectionsPages::UPtr all_collections(const Collection::Sort sort, const int32_t where, const int32_t start_page);
		ProfileCollectionsPages::UPtr profile_collections(const ProfileID profile_id, const int32_t start_page);
		ReleaseCollectionsPages::UPtr release_collections(const ReleaseID release_id, const Collection::Sort sort, const int32_t start_page);
		CollectionReleasesPages::UPtr collection_releases(const CollectionID collection_id, const int32_t start_page);
		void report_collection(const CollectionID collection_id, const requests::CollectionReportRequest& request);

		void add_collection_comment(const CollectionID collection_id, const requests::CollectionCommentAddRequest& request);
		CollectionComment::Ptr get_collection_comment(const CollectionID collection_id); // wtf?
		CollectionCommentsPages::UPtr collection_comments(const CollectionID collection_id, const CollectionComment::Sign sort, const int32_t start_page);
		void remove_comment(const CollectionCommentID comment_id);
		void edit_comment(const CollectionCommentID comment_id, const requests::CollectionCommentEditRequest& request);
		void process_comment(const CollectionCommentID comment_id, const requests::ReleaseCommentProcessRequest& request);
		ProfileCollectionCommentsPages::UPtr profile_collection_comments(const ProfileID profile_id, const CollectionComment::Sort sort, const int32_t start_page);
		CollectionCommentRepliesPages::UPtr collection_comment_replies(const CollectionCommentID comment_id, const CollectionComment::Sign sort, const int32_t start_page);
		void report_collection_comment(const CollectionCommentID comment_id, const requests::CollectionCommentReportRequest& request);
		void vote_collection_comment(const CollectionCommentID comment_id, const CollectionComment::Sign vote);

		void add_collection_to_favorites(const CollectionID collection_id);
		void remove_collection_from_favorites(const CollectionID collection_id);
		FavoriteCollectionsPages::UPtr my_favorite_collections(const int32_t start_page);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}