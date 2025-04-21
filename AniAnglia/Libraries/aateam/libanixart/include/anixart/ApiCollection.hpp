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

		Comment::Ptr add_collection_comment(const CollectionID collection_id, const requests::CommentAddRequest& request);
		Comment::Ptr collection_comment(const CommentID comment_id);
		CollectionCommentsPages::UPtr collection_comments(const CollectionID collection_id, const Comment::Sort sort, const int32_t start_page);
		void remove_comment(const CommentID comment_id);
		void edit_comment(const CommentID comment_id, const requests::CommentEditRequest& request);
		void process_comment(const CommentID comment_id, const requests::CommentProcessRequest& request);
		CollectionCommentRepliesPages::UPtr replies_to_comment(const CommentID comment_id, const Comment::Sort sort, const int32_t start_page);
		void report_collection_comment(const CommentID comment_id, const requests::CommentReportRequest& request);
		void vote_collection_comment(const CommentID comment_id, const Comment::Sign vote);

		void add_collection_to_favorites(const CollectionID collection_id);
		void remove_collection_from_favorites(const CollectionID collection_id);
		FavoriteCollectionsPages::UPtr my_favorite_collections(const int32_t start_page);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}