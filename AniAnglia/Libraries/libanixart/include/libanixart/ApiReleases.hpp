#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"
#include "ApiTypes.hpp"

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
		ReleaseCommentsPages::UniqPtr release_comments(const int64_t& release_id, const int32_t& start_page, const ReleaseComment::FilterBy& filter_by);
		void process_release_comment(const int64_t& comment_id, const requests::ReleaseCommentProcessRequest& process_request);
		ReleaseCommentRepliesPages::UniqPtr get_replies_to_comment(const int64_t& comment_id, const int32_t& start_page, const ReleaseComment::FilterBy& filter_by);
		void report_release_comment(const int64_t& comment_id, const requests::ReleaseCommentReportRequest& report_request);
		void vote_release_comment(const int64_t& comment_id, const ReleaseComment::Sign& sign);

		std::vector<ReleaseVideoCategory::Ptr> release_video_categories();
		ReleaseVideoCategoryPages::UniqPtr release_video_category(const int64_t& release_id, const int64_t& category_id, const int32_t& start_page);
		std::vector<ReleaseVideoBlock::Ptr> release_video_main(const int64_t& release_id);
		ReleaseVideoPages::UniqPtr release_videos(const int64_t& release_id, const int32_t& start_page);
		ProfileReleaseVideoPages::UniqPtr profile_release_videos(const int64_t& profile_id, const int32_t& start_page);

		void raise_release_appeal(const requests::ReleaseVideoAppealRequest& appeal_request);
		void remove_release_appeal(const int64_t& appeal_id);
		ReleaseVideoAppealPages::UniqPtr my_appeals(const int32_t& start_page);
		std::vector<ReleaseVideo::Ptr> my_last_appeals();

		void add_release_to_favorites(const int64_t& release_id);
		void remove_release_from_favorites(const int64_t& release_id);
		ProfileReleaseVideoFavoritesPages::UniqPtr profile_favorites(const int64_t& profile_id, const int32_t& start_page);

		void add_to_history(const int64_t& release_id, const int64_t& source_id, const int32_t& position);
		void remove_release_from_history(const int64_t& release_id);
		HistoryPages::UniqPtr get_history(const int32_t& start_page);

		void add_release_to_profile_list(const int64_t& release_id, const ProfileList::Status& status);
		void remove_release_from_profile_list(const int64_t& release_id, const ProfileList::Status& status);
		ProfileListPages::UniqPtr my_profile_list(const ProfileList::Status& status, const ProfileList::Sort& sort, const int32_t& start_page);
		ProfileListByProfilePages::UniqPtr profile_list(const int64_t& profile_id, const ProfileList::Status& status, const ProfileList::Sort& sort, const int32_t& start_page);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
};

