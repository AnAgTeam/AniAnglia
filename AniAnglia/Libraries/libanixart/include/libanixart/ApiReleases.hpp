#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {
	class ApiReleases {
	public:
		ApiReleases(const ApiSession& session, const std::string& token);

		void release_vote(const int64_t& release_id, const int32_t& vote) const;
		void delete_release_vote(const int64_t& release_id) const;
		Release::Ptr random_release(const int64_t& release_id) const;
		Release::Ptr random_collection_release(const int64_t& release_id) const;
		Release::Ptr random_favority_release(const int64_t& release_id) const;
		Release::Ptr random_profile_release(const int64_t& profile_id, const int32_t& status) const;
		Release::Ptr get_release(const int64_t& release_id) const;

		ReleaseComment::Ptr add_release_comment(const int64_t& release_id, const requests::ReleaseCommentAddRequest& add_request);
		ReleaseComment::Ptr release_comment(const int64_t& release_id);
		void remove_release_comment(const int64_t& comment_id);
		ReleaseCommentsPages release_comments(const int64_t& release_id, const int32_t& start_page, const ReleaseCommentsSort& sort);
		void process_release_comment(const int64_t& comment_id, const requests::ReleaseCommentProcessRequest& process_request);
		ReleaseCommentRepliesPages get_replies_to_comment(const int64_t& comment_id, const int32_t& start_page, const ReleaseCommentsSort& sort);
		void report_release_comment(const int64_t& comment_id, const requests::ReleaseCommentReportRequest& report_request);
		void vote_release_comment(const int64_t& comment_id, const CommentVoteType& type);

		std::vector<ReleaseVideoCategory::Ptr> release_video_categories();
		ReleaseVideoCategoryPages release_video_category(const int64_t& release_id, const int64_t& category_id, const int32_t& start_page);
		std::vector<ReleaseVideoBlock::Ptr> release_video_main(const int64_t& release_id);
		ReleaseVideoPages release_videos(const int64_t& release_id, const int32_t& start_page);
		ProfileReleaseVideoPages profile_release_videos(const int64_t& profile_id, const int32_t& start_page);

		void raise_release_appeal(const requests::ReleaseVideoAppealRequest& appeal_request);
		void remove_release_appeal(const int64_t& appeal_id);
		ReleaseVideoAppealPages my_appeals(const int32_t& start_page);
		std::vector<ReleaseVideo::Ptr> my_last_appeals();

		void add_release_to_favorites(const int64_t& release_id);
		void remove_release_from_favorites(const int64_t& release_id);
		ProfileReleaseVideoFavoritesPages profile_favorites(const int64_t& profile_id, const int32_t& start_page);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
};

