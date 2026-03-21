#pragma once
#include <anixart/ApiTypes.hpp>
#include <anixart/Serializable.hpp>
#include <anixart/StrongTypedef.hpp>
#include <netsess/JsonTools.hpp>
#include <netsess/JsonTools.hpp>

#include <vector>
#include <string>

namespace anixart {
	namespace requests {
		namespace aux {
			struct ArticleReportReasonTag {};
			struct ArticleCommentReportReasonTag {};
			struct ReleaseCommentReportReasonTag {};
			struct CollectionCommentReportReasonTag {};
			struct ReleaseReportReasonTag {};
			struct CollectionReportReasonTag {};
			struct ProfileReportReasonTag {};
			struct EpisodeReportReasonTag {};
			struct ChannelReportReasonTag {};
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
				Year = 2,
				Popular = 3
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

		class DeprecatedReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason;
		};

		template<typename ID, typename Tag>
		class ReportRequest : Serializable {
		public:
			using EntityID = ID;
			using Reason = anixart::aux::StrongTypedef<int64_t, Tag>;

			std::string serialize() const override {
				using namespace network::json;
				std::string json;
				InlineJson::open_object(json);
				InlineJson::append(json, "entity_id", static_cast<int64_t>(entity_id));
				InlineJson::append(json, "message", message);
				InlineJson::append(json, "reason", static_cast<int64_t>(reason));
				InlineJson::close_object(json);
				return json;
			}

			operator DeprecatedReportRequest() const {
				DeprecatedReportRequest req;
				req.message = message;
				req.reason = static_cast<int64_t>(reason);
				return req;
			}

			EntityID entity_id;
			std::string message;
			Reason reason;
		};

		using ArticleReportRequest = ReportRequest<ChannelID, aux::ArticleReportReasonTag>;
		using ArticleCommentReportRequest = ReportRequest<CommentID, aux::ArticleCommentReportReasonTag>;
		using ReleaseCommentReportRequest = ReportRequest<CommentID, aux::ReleaseCommentReportReasonTag>;
		using CollectionCommentReportRequest = ReportRequest<CommentID, aux::CollectionCommentReportReasonTag>;
		using ProfileReportRequest = ReportRequest<ProfileID, aux::ProfileReportReasonTag>;
		using ReleaseReportRequest = ReportRequest<ReleaseID, aux::ReleaseReportReasonTag>;
		using CollectionReportRequest = ReportRequest<CollectionID, aux::CollectionReportReasonTag>;
		using EpisodeReportRequest = ReportRequest<EpisodeID, aux::EpisodeReportReasonTag>;
		using ChannelReportRequest = ReportRequest<EpisodeID, aux::ChannelReportReasonTag>;

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

		class CommentAddRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			std::string message;
			std::optional<CommentID> parent_comment_id;
			std::optional<ProfileID> reply_to_profile_id;
		};

		class CommentEditRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			std::string message;
		};

		class CommentProcessRequest : Serializable {
		public:

			std::string serialize() const override;

			bool is_spoiler;
			bool is_deleted;
			bool is_banned;
			std::string ban_reason;
			TimestampPoint ban_expires;
		};

		class ReleaseVideoAppealRequest : Serializable {
		public:

			std::string serialize() const override;

			ReleaseID release_id;
			ReleaseVideoCategoryID category_id;
			std::string title;
			std::string url;
		};

		class CreateEditCollectionRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string title;
			std::string description;
			std::vector<ReleaseID> release_ids;
			bool is_private;
		};

		class ArticlesFilterRequest : Serializable {
		public:

			enum class Sort {
				DateNone = 0,
				DateToday = 1,
				DateDay = 2,
				DateWeek = 3,
				DateMonth = 4,
				DateYear = 5,
				DateWholeTime = 6
			};

			enum class DateFilter {
				None = 0,
				Today = 1,
				LastFullDay = 2, // 24 hours
				Week = 3,
				Month = 4,
				Year = 5,
				AllTime = 6
			};

			std::string serialize() const override;

			ChannelID channel_id;
			DateFilter date_filter;
		};

		class ArticleCreateEditRequest : Serializable {
		public:

			std::string serialize() const override;
			
			std::string payload;
			std::optional<ArticleID> repost_article_id; // TODO: check
		};

		class ArticleSuggestionsFilterRequest : Serializable {
		public:

			std::string serialize() const override;

			ChannelID channel_id;
		};

		class ArticleSuggestionCreateEditRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string payload;
		};

		class ChannelBlockManageRequest : Serializable {
		public:

			std::string serialize() const override;

			std::optional<TimestampPoint> expire_date;
			std::optional<std::string> reason;
			ProfileID target_profile_id;
			bool is_blocked;
			bool is_perm_banned;
			bool is_reason_showing_enabled;
		};

		class ChannelCreateEditRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string title;
			std::string description;
			bool is_article_suggestion_enabled;
			bool is_commenting_enabled;
		};

		class ChannelPermissionManageRequest : Serializable {
		public:

			std::string serialize() const override;

			Channel::Permission permission; // TODO: check
			ProfileID target_profile_id;
		};

		class ChannelPermissionsFilterRequest : Serializable {
		public:

			std::string serialize() const override;

			Channel::Permission permission; //TODO: check
		};

		class ChannelsFilterRequest : Serializable {
		public:

			enum class Sort {
				None = 0,
				SubscriberCount = 1
			};

			std::string serialize() const override;

			std::optional<bool> is_blog;
			std::optional<bool> is_subscribed;
			Sort sort;
			Channel::Permission permission; // 1 - feed, 0 - ???. TODO: check
		};

	}
}