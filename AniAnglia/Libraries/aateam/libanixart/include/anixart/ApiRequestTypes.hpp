#pragma once
#include <anixart/ApiTypes.hpp>
#include <netsess/JsonTools.hpp>

#include <vector>
#include <string>

namespace anixart {
	namespace requests {
		class Serializable {
		public:
			virtual std::string serialize() const = 0;
		};

		class BookmarksImportRequest {
		public:
			std::vector<ReleaseID> completed; // todo: verify
			std::vector<ReleaseID> dropped;
			std::vector<ReleaseID> hold_on;
			std::vector<ReleaseID> plans;
			std::vector<ReleaseID> watching;
			std::string selected_importer_name;
		};
		class BookmarksExportRequest {
		public:
			std::vector<ProfileID> bookmarks_export_profile_lists; // todo: verify
		};

		class FilterRequest : Serializable {
		public:
			enum Sort {
				DateUpdate = 0,
				Grade = 1,
				Year = 2
			};

			std::string serialize() const override;

			std::optional<Release::Category> category;
			std::optional<std::string> country;
			std::optional<std::chrono::years> start_year;
			std::optional<std::chrono::years> end_year;
			std::optional<std::chrono::minutes> episode_duration_from;
			std::optional<std::chrono::minutes> episode_duration_to;
			std::optional<int32_t> episodes_count_from;
			std::optional<int32_t> episodes_count_to;
			std::optional<Release::Season> season;
			std::optional<Release::Status> status;
			std::optional<std::string> studio;
			std::optional<Sort> sort;
			bool is_genres_exclude_mode = false;
			std::vector<std::string> genres;
			std::vector<Profile::List> profile_list_exclusions; // todo: check
			std::vector<EpisodeTypeID> types;
			std::vector<Release::AgeRating> age_ratings;
		};

		class SearchRequest : Serializable {
		public:
			enum class SearchBy {
				Basic = 0,
				ByStudio = 1,
				ByDirector = 2,
				ByAuthor = 3,
				ByGenre = 4
			};

			std::string serialize() const override;

			std::string query;
			SearchBy search_by = SearchBy::Basic;
		};

		class DirectLinkRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string url;
		};

		class ReleaseReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason;
		};

		template<typename T>
		class ReportRequest : Serializable {
		public:
			typedef std::shared_ptr<T> ValuePtr;

			std::string serialize() const override {
				// Not implemented
				throw std::exception();
			}

			ValuePtr entity;
			std::string message;
			int64_t reason;
		};
		using EpisodeReportRequest = ReportRequest<Episode>;

		class ProfileProcessRequest : Serializable {
		public:

			std::string serialize() const override;

			std::optional<TimestampPoint> ban_expires;
			std::optional<std::string> ban_reason;
			bool is_banned;

		};

		class PrivacyEditRequest : Serializable {
		public:

			std::string serialize() const override;

			int32_t permission;
		};

		class SocialPagesEditRequest : Serializable {
		public:
			SocialPagesEditRequest(const ProfileSocial& social);

			std::string serialize() const override;

			std::string discord_page;
			std::string instagram_page;
			std::string telegram_page;
			std::string tiktok_page;
			std::string vk_page;
		};

		class StatusEditRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string status;
		};

		class ReleaseCommentAddRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			std::string message;
			std::optional<ReleaseCommentID> parent_comment_id;
			std::optional<ProfileID> reply_to_profile_id;
		};

		class ReleaseCommentEditRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			std::string message;
		};

		class ReleaseCommentProcessRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			bool is_deleted;
			bool is_banned;
			std::string ban_reason;
			TimestampPoint ban_expires;
		};

		class ReleaseCommentReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason;
		};

		class ReleaseVideoAppealRequest : Serializable {
		public:

			std::string serialize() const override;

			ReleaseID release_id;
			ReleaseVideoCategoryID category_id;
			std::string title;
			std::string url;
		};

		class CollectionReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason; // todo: check
		};

		class CollectionCommentAddRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			std::optional<CollectionCommentID> parent_comment_id;
			std::optional<ProfileID> reply_to_profile_id;
			bool spoiler;
		};

		class CollectionCommentEditRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			bool spoiler;
		};

		class CollectionCommentReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason;
		};

		class CreateEditCollectionRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string title;
			std::string description;
			std::vector<ReleaseID> release_ids;
			bool is_private;
		};
	}
}