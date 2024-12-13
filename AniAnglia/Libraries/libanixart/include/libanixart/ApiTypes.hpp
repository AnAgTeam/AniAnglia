#pragma once
#include "NetTypes.hpp"

#include <chrono>
#include <vector>

namespace libanixart {
	// Internal type
	struct ProfileList {
		enum class Sort {
			Descending = 1,
			Ascending = 2,
			ReleaseDescending = 3,
			ReleaseAscending = 4,
			TitleDescending = 5,
			TitleAscending = 6
		};
		enum class Status {
			NotWatching = 0,
			Watching = 1,
			Plan = 2,
			Watched = 3,
			HoldOn = 4,
			Dropped = 5
		};
	};

	using time_point = std::chrono::system_clock::time_point;
	class ProfileToken {
	public:
		ProfileToken(const int64_t id, const std::string& token);
		ProfileToken(JsonObject& token_object);

		int64_t id;
		std::string token;
	};
	class Profile {
	public:
		using Ptr = std::shared_ptr<Profile>;
		Profile(JsonObject& object);

		enum class PrivilegeLevel {
			None = 0,
			Member = 1,
			Releaser = 2,
			Moderator = 3,
			Administrator = 4,
			Developer = 5
		};

		int64_t id;
		std::string login;
		std::string avatar_url;
		std::string status;
		std::string telegram_page;
		std::string vk_page;
		std::string instagram_page;
		std::string discord_page;
		std::string tt_page;

		bool is_banned;
		bool is_perm_banned;
		time_point ban_expires;
		std::string ban_reason;

		PrivilegeLevel privilege_level;
		int64_t watched_time;
		int32_t completed_count;
		int32_t dropped_count;
		int32_t watching_count;
		int32_t plan_count;
		int32_t hold_on_count;
		int32_t favorite_count;
		int32_t video_count;
		int32_t watched_episode_count;
		int32_t comment_count;
		int32_t collection_count;
		int32_t rating_score;
		int32_t friend_status;
		int32_t friend_count;
		time_point last_activity_time;
		time_point register_date;

		
		bool is_blocked;
		bool is_me_blocked;
		time_point block_added_date;

		bool is_sponsor;
		time_point sponsorship_expires;

		bool is_online;
		bool is_verified;
		bool is_social;
		bool is_social_hidden;
		bool is_stats_hidden;
		bool is_counts_hidden;
		bool is_release_type_notifications_enabled;
		bool is_related_release_notifications_enabled;
		bool is_report_process_notifications_enabled;
		bool is_my_collection_comment_notifications_enabled;
		bool is_my_article_comment_notifications_enabled;
		bool is_comment_notifications_enabled;
		bool is_episode_notifications_enabled;
		bool is_first_episode_notification_enabled;
		bool is_friend_requests_disallowed;
		bool is_login_changed;
		bool is_vk_bound;
		bool is_google_bound;
	};

	class EpisodeUpdate {
	public:
		using Ptr = std::shared_ptr<EpisodeUpdate>;
		EpisodeUpdate(JsonObject& object);

		int64_t last_episode_source_update_id;
		int64_t last_episode_type_update_id;
		time_point last_episode_update_date;
		std::string last_episode_update_name;
		std::string last_episode_source_update_name;
		std::string last_episode_type_update_name;
	};
	class EpisodeSource {
	public:
		using Ptr = std::shared_ptr<EpisodeSource>;
		EpisodeSource(JsonObject& object);

		int64_t id;
		std::string name;
		int64_t episodes_count;
	};
	/* Типо озвучка */
	class EpisodeType {
	public:
		using Ptr = std::shared_ptr<EpisodeType>;
		EpisodeType(JsonObject& object);

		int64_t id;
		int64_t view_count;
		int64_t episodes_count;
		std::string name;
		std::string workers;
	};
	class Episode {
	public:
		using Ptr = std::shared_ptr<Episode>;
		Episode(JsonObject& object);

		enum class Sort {
			FromLeast = 1,
			FromGreatest = 2
		};

		int64_t id;
		std::string name;
		std::string url;
		int64_t release_id;
		int64_t source_id;
		int64_t playback_position;
		int32_t position;

		bool is_watched;
		bool is_filler;
	};
	
	class Release {
	public:
		using Ptr = std::shared_ptr<Release>;
		
		Release(JsonObject& object);

		enum class Status {
			Unknown = 0,
			Finished = 1,
			Ongoing = 2,
			Upcoming = 3
		};
		enum class Category {
			Unknown = 0,
			Series = 1,
			Movies = 2,
			Ova = 3
		};
		enum class ByVoteSort {
			Descending = 1,
			Ascending = 2,
			FiveStar = 3,
			FourStar = 4,
			ThreeStar = 5,
			TwoStar = 6,
			OneStar = 7
		};

		int64_t id;
		std::string title_original;
		std::string title_ru;
		std::string title_alt;
		std::string description;
		std::string author;
		std::string director;
		std::string studio;
		std::string image_url;
		std::string country;
		std::string translators;
		std::string year;
		std::string genres;
		int32_t rating;
		double grade;
		Status status; // fake property
		Category category; // fake property
		int32_t season;
		std::string release_date;
		time_point creation_date;
		time_point last_update_date;

		int32_t age_rating;
		int32_t duration;
		int32_t broadcast;
		int64_t aired_on_date;
		int32_t profile_release_type_notification_preference_count;
		int32_t vote1_count;
		int32_t vote2_count;
		int32_t vote3_count;
		int32_t vote4_count;
		int32_t vote5_count;
		int32_t vote_count;
		int32_t your_vote;
		time_point voted_date;
		int32_t my_vote;

		int32_t episodes_total;
		int64_t collection_count;
		int32_t favorite_count;
		int64_t comment_count;
		int32_t comment_per_day_count;
		int32_t completed_count;
		int32_t dropped_count;
		int32_t hold_on_count;
		int32_t plan_count;
		int32_t watching_count;

		EpisodeUpdate::Ptr episode_last_update;
		int32_t episodes_released;

		time_point last_set_completed_date;
		time_point last_set_dropped_date;
		time_point last_set_favorite_date;
		time_point last_set_hold_on_date;
		time_point last_set_plan_date;
		time_point last_set_viewed_date;
		time_point last_set_watching_date;
		time_point last_view_date;
		std::string last_view_episode_name;
		std::string last_view_episode_type_name;

		std::string note;
		ProfileList::Status profile_list_status;

		bool is_adult;
		bool is_deleted;
		bool is_favorite;
		bool is_viewed;
		bool is_play_disabled;
		bool is_release_type_notifications_enabled;
		bool is_third_party_platforms_disabled;
		bool is_view_blocked;
		bool can_torlook_search;
		bool can_video_appeal;
	};
	class ReleaseVideoCategory {
	public:
		using Ptr = std::shared_ptr<ReleaseVideoCategory>;
		ReleaseVideoCategory();
		ReleaseVideoCategory(JsonObject& object);

		int64_t id;
		std::string name;
	};
	class ReleaseVideoHosting {
	public:
		using Ptr = std::shared_ptr<ReleaseVideoHosting>;
		ReleaseVideoHosting(JsonObject& object);

		int64_t id;
		std::string name;
		std::string icon_url;
	};
	class ReleaseComment {
	public:
		using Ptr = std::shared_ptr<ReleaseComment>;
		ReleaseComment(JsonObject& object);

		enum class FilterBy {
			All = 1,
			Negative = 2,
			Positive = 3
		};
		enum class Sort {
			Newest = 1,
			Oldest = 2,
			Popular = 3
		};
		enum class Sign {
			Neutral = 0,
			Negative = 1,
			Positive = 2
		};

		int64_t id;
		int64_t parent_comment_id;
		std::string message;
		int32_t vote;
		int32_t vote_count;
		int64_t reply_count;
		time_point date;

		bool is_deleted;
		bool is_edited;
		bool is_spoiler;
	};
	class ReleaseVideo {
	public:
		using Ptr = std::shared_ptr<ReleaseVideo>;
		ReleaseVideo(JsonObject& object);

		int64_t id;
		std::string title;
		std::string image_url;
		std::string url;
		std::string player_url;
		time_point date;
		ReleaseVideoCategory::Ptr category;
		ReleaseVideoHosting::Ptr hosting;
		Profile::Ptr profile;
		Release::Ptr release;

		int32_t favorite_count;

		bool is_favorite;
	};
	class ReleaseVideoBlock {
	public:
		using Ptr = std::shared_ptr<ReleaseVideoBlock>;
		ReleaseVideoBlock(JsonObject& object);

		ReleaseVideoCategory::Ptr category;
		std::vector<ReleaseVideo::Ptr> videos;
	};
	class ReleaseStreamingPlatform {
	public:
		using Ptr = std::shared_ptr<ReleaseStreamingPlatform>;
		ReleaseStreamingPlatform(JsonObject& object);

		int64_t id;
		std::string name;
		std::string icon_url;
		std::string url;
	};
	class ReleaseVideos {
	public:
		using Ptr = std::shared_ptr<ReleaseVideos>;
		ReleaseVideos(JsonObject& object);

		std::vector<ReleaseVideoBlock::Ptr> blocks;
		std::vector<ReleaseVideo::Ptr> last_videos;
		std::vector<ReleaseStreamingPlatform::Ptr> streaming_platforms;
		Release::Ptr release;
	};

	class Collection {
	public:
		using Ptr = std::shared_ptr<Collection>;
		Collection(JsonObject& object);

		enum class Sort {
			RatingLeader = 1,
			YearPopular = 2,
			SeasonPopular = 3,
			WeekPopular = 4,
			RecentlyAdded = 5,
			Random = 6
		};

		int64_t id;
		std::string title;
		std::string description;
		std::string creator;
		std::string image_url;
		time_point last_update_date;
		time_point creation_date;

		std::vector<Release::Ptr> releases;

		int64_t comment_count;
		int32_t favorite_count;

		bool is_favorite;
		bool is_private;
	};

	class Category {
	public:
		using Ptr = std::shared_ptr<Category>;
		Category(JsonObject& object);


	};
	class Related {
	public:
		using Ptr = std::shared_ptr<Related>;
		Related(JsonObject& object);


	};
	class Interesting {
	public:
		using Ptr = std::shared_ptr<Interesting>;
		Interesting(JsonObject& object);

		int64_t id;
		int32_t type;
		std::string title;
		std::string description;
		std::string image_url;
		std::string action;

		bool is_hidden;
	};
	class LoginChange {
	public:
		using Ptr = std::shared_ptr<LoginChange>;
		LoginChange(JsonObject& object);

		int64_t id;
		std::string new_login;
		time_point date;
	};
	class ProfileSocial {
	public:
		using Ptr = std::shared_ptr<ProfileSocial>;
		ProfileSocial(JsonObject& object);

		std::string discord_page;
		std::string instagram_page;
		std::string telegram_page;
		std::string tiktok_page;
		std::string vk_page;
	};

	/* --- Some api response types --- */
	class ProfilePreferenceStatus {
	public:
		using Ptr = std::shared_ptr<ProfilePreferenceStatus>;
		ProfilePreferenceStatus(JsonObject& object);

		time_point change_avatar_ban_expires;
		time_point change_login_ban_expires;
		bool is_change_avatar_banned;
		bool is_change_login_banned;
		bool is_google_bound;
		bool is_vk_bound;
		bool is_login_changed;
		int32_t privacy_counts;
		int32_t privacy_friend_requests;
		int32_t privacy_social;
		int32_t privacy_stats;
		std::string avatar_url;
		std::string status;
		std::string vk_page;
		std::string tg_page;
	};
	class LoginChangeInfo {
	public:
		using Ptr = std::shared_ptr<LoginChangeInfo>;
		LoginChangeInfo(JsonObject& object);

		bool is_change_available;
		time_point last_change_date;
		time_point next_change_available_date;
		std::string login;
		std::string avatar_url;
	};
}

