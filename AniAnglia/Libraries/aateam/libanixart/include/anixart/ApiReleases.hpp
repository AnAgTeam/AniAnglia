#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiPageableRequests.hpp>
#include <anixart/ApiTypes.hpp>

namespace anixart {
	class ApiReleases {
	public:
		ApiReleases(const ApiSession& session, const std::string& token);

		void release_vote(const ReleaseID release_id, const int32_t vote) const;
		void delete_release_vote(const ReleaseID release_id) const;
		Release::Ptr random_release(const ReleaseID release_id) const;
		Release::Ptr random_collection_release(const ReleaseID release_id) const;
		Release::Ptr random_favorite_release(const ReleaseID release_id) const;
		Release::Ptr random_profile_release(const ProfileID profile_id, const Release::Status status) const;
		Release::Ptr get_release(const ReleaseID release_id) const;

		ReleaseComment::Ptr add_release_comment(const ReleaseID release_id, const requests::ReleaseCommentAddRequest& add_request) const;
		ReleaseComment::Ptr release_comment(const ReleaseID release_id) const;
		void remove_release_comment(const ReleaseCommentID comment_id) const;
		ReleaseCommentsPages::UPtr release_comments(const ReleaseID release_id, const int32_t start_page, const ReleaseComment::FilterBy filter_by) const;
		void process_release_comment(const ReleaseCommentID comment_id, const requests::ReleaseCommentProcessRequest& process_request) const;
		ReleaseCommentRepliesPages::UPtr get_replies_to_comment(const ReleaseCommentID comment_id, const int32_t start_page, const ReleaseComment::FilterBy filter_by) const;
		void report_release_comment(const ReleaseCommentID comment_id, const requests::ReleaseCommentReportRequest& report_request) const;
		void vote_release_comment(const ReleaseCommentID comment_id, const ReleaseComment::Sign sign) const;

		std::vector<ReleaseVideoCategory::Ptr> release_video_categories() const;
		ReleaseVideoCategoryPages::UPtr release_video_category(const ReleaseID release_id, const ReleaseVideoCategoryID category_id, const int32_t start_page) const;
		std::vector<ReleaseVideoBlock::Ptr> release_video_main(const ReleaseID release_id) const;
		ReleaseVideoPages::UPtr release_videos(const ReleaseID release_id, const int32_t start_page) const;
		ProfileReleaseVideoPages::UPtr profile_release_videos(const ProfileID profile_id, const int32_t start_page) const;

		void raise_release_appeal(const requests::ReleaseVideoAppealRequest& appeal_request) const;
		void remove_release_appeal(const ReleaseVideoID video_appeal_id) const;
		ReleaseVideoAppealPages::UPtr my_appeals(const int32_t start_page) const;
		std::vector<ReleaseVideo::Ptr> my_last_appeals();

		void add_release_to_favorites(const ReleaseID release_id) const;
		void remove_release_from_favorites(const ReleaseID release_id) const;
		ProfileFavoriteReleasesPages::UPtr profile_favorites(const ProfileID profile_id, const Profile::ListSort sort, const int32_t filter_announce, const int32_t start_page) const;

		void add_release_video_to_favorites(const ReleaseVideoID release_video_id) const;
		void remove_release_video_from_favorites(const ReleaseVideoID release_video_id) const;
		ProfileReleaseVideoFavoritesPages::UPtr profile_favorite_videos(const ProfileID profile_id, const int32_t start_page) const;

		void add_to_history(const ReleaseID release_id, const EpisodeSourceID source_id, const int32_t position) const;
		void remove_release_from_history(const ReleaseID release_id) const;
		HistoryPages::UPtr get_history(const int32_t start_page) const;

		void add_release_to_profile_list(const ReleaseID release_id, const Profile::ListStatus status) const;
		void remove_release_from_profile_list(const ReleaseID release_id, const Profile::ListStatus status) const;
		ProfileListPages::UPtr my_profile_list(const Profile::ListStatus status, const Profile::ListSort sort, const int32_t start_page) const;
		ProfileListByProfilePages::UPtr profile_list(const ProfileID profile_id, const Profile::ListStatus status, const Profile::ListSort sort, const int32_t start_page) const;

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
};

