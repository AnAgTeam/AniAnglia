#pragma once
#include "JsonTools.hpp"
#include "ApiTypes.hpp"

#include <vector>
#include <string>

namespace libanixart {
	namespace requests {
		class Serializable {
		public:
			virtual std::string serialize() const = 0;
		};

		class BookmarksImportRequest {
		public:
			std::vector<int64_t> completed;
			std::vector<int64_t> dropped;
			std::vector<int64_t> hold_on;
			std::vector<int64_t> plans;
			std::vector<int64_t> watching;
			std::string selected_importer_name;
		};
		class BookmarksExportRequest {
		public:
			std::vector<int64_t> bookmarks_export_profile_lists;
		};

		class FilterRequest : Serializable {
		public:
			enum Sort {
				SortDateUpdate = 0,
				SortGrade = 1,
				SortYear = 2
			};

			std::string serialize() const override;

			json::Nullable<Release::Category> category;
			json::Nullable<std::string> country;
			json::Nullable<int32_t> start_year;
			json::Nullable<int32_t> end_year;
			json::Nullable<int32_t> episode_duration_from;
			json::Nullable<int32_t> episode_duration_to;
			json::Nullable<int32_t> episodes_count_from;
			json::Nullable<int32_t> episodes_count_to;
			json::Nullable<int32_t> season;
			json::Nullable<Release::Status> status;
			json::Nullable<std::string> studio;
			json::Nullable<Sort> sort;
			bool is_genres_exclude_mode = false;
			std::vector<std::string> genres;
			std::vector<int32_t> profile_list_exclusions;
			std::vector<int64_t> types;
			std::vector<int32_t> age_ratings;
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
			typedef std::shared_ptr<T> TTypePtr;

			std::string serialize() const override {
				// Not implemented
				throw std::exception();
			}

			TTypePtr entity;
			std::string message;
			int64_t reason;
		};
		using EpisodeReportRequest = ReportRequest<Episode>;

		class ProfileProcessRequest : Serializable {
		public:

			std::string serialize() const override;

			json::Nullable<int64_t> ban_expires;
			json::Nullable<std::string> ban_reason;
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
			json::Nullable<int64_t> parent_comment_id;
			json::Nullable<int64_t> reply_to_profile_id;
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
			time_point ban_expires;
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

			int64_t release_id;
			int64_t category_id;
			std::string title;
			std::string url;
		};
	}
}