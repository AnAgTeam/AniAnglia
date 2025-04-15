#pragma once
#include <anixart/StrongTypedef.hpp>
#include <anixart/CachingJson.hpp>
#include <netsess/NetTypes.hpp>
#include <chrono>
#include <vector>

namespace anixart {
	namespace aux {
		struct ProfileIDTag {};
		struct ReleaseIDTag {};
		struct EpisodeIDTag {};
		struct EpisodeSourceIDTag {};
		struct EpisodeTypeIDTag {};
		struct CollectionIDTag {};
		struct InterestingIDTag {};
		struct CommentIDTag {};
		struct ReleaseVideoIDTag {};
		struct LoginChangeIDTag {};
		struct ReleaseStreamingPlatformIDTag {};
		struct ReleaseVideoCategoryIDTag {};
		struct ReleaseVideoHostingIDTag {};
		struct ProfileWatchDynamicIDTag {};
		struct RoleIDTag {};
		namespace experimental {
			struct BadgeIDTag {};
		};
	};

	using ProfileID = aux::StrongTypedef<int64_t, aux::ProfileIDTag>;
	using ReleaseID = aux::StrongTypedef<int64_t, aux::ReleaseIDTag>;
	using EpisodeID = aux::StrongTypedef<int64_t, aux::EpisodeIDTag>;
	using EpisodeSourceID = aux::StrongTypedef<int64_t, aux::EpisodeSourceIDTag>;
	using EpisodeTypeID = aux::StrongTypedef<int64_t, aux::EpisodeTypeIDTag>;
	using CollectionID = aux::StrongTypedef<int64_t, aux::CollectionIDTag>;
	using InterestingID = aux::StrongTypedef<int64_t, aux::InterestingIDTag>;
	using CommentID = aux::StrongTypedef<int64_t, aux::CommentIDTag>;
	using ReleaseVideoID = aux::StrongTypedef<int64_t, aux::ReleaseVideoIDTag>;
	using LoginChangeID = aux::StrongTypedef<int64_t, aux::LoginChangeIDTag>;
	using ReleaseStreamingPlatformID = aux::StrongTypedef<int64_t, aux::ReleaseStreamingPlatformIDTag>;
	using ReleaseVideoCategoryID = aux::StrongTypedef<int64_t, aux::ReleaseVideoCategoryIDTag>;
	using ReleaseVideoHostingID = aux::StrongTypedef<int64_t, aux::ReleaseVideoHostingIDTag>;
	using ProfileWatchDynamicID = aux::StrongTypedef<int64_t, aux::ProfileWatchDynamicIDTag>;
	using RoleID = aux::StrongTypedef<int64_t, aux::RoleIDTag>;

	//using Clock = std::chrono::system_clock;
	using TimestampDuration = std::chrono::seconds;
	using TimestampPoint = std::chrono::time_point<std::chrono::system_clock, TimestampDuration>;

	namespace experimental {
		using BadgeID = aux::StrongTypedef<int64_t, aux::experimental::BadgeIDTag>;
		class Bagde {
		public:
			BadgeID id;
			int64_t type;
			std::string name;
			TimestampPoint date;
			std::string image_url; // actually a JSON file url. Probably vector graphics
		};
	}

	class ProfileToken {
	public:
		ProfileToken() = default;
		ProfileToken(const int64_t id, const std::string& token);
		ProfileToken(json::CachingJsonObject& object);

		int64_t id;
		std::string token;
	};

	class ProfileWatchDynamic {
	public:
		using Ptr = std::shared_ptr<ProfileWatchDynamic>;
		ProfileWatchDynamic(json::CachingJsonObject& object);

		ProfileWatchDynamicID id;
		std::chrono::day day;
		int32_t watched_count;
		TimestampPoint date;
	};

	class Role {
	public:
		using Ptr = std::shared_ptr<Role>;
		Role(json::CachingJsonObject& object);

		RoleID id;
		std::string name;
		std::string color;
	};

	class Release;
	class Collection;

	class Profile {
	public:
		using Ptr = std::shared_ptr<Profile>;
		Profile(json::CachingJsonObject& object);

		enum class PrivilegeLevel {
			None = 0,
			Member = 1,
			Releaser = 2,
			Moderator = 3,
			Administrator = 4,
			Developer = 5
			// ??? = 6
		};

		enum class List {
			Favorite = 0,
			Watching = 1,
			Plan = 2,
			Watched = 3,
			HoldOn = 4,
			Dropped = 5
		};
		enum class ListSort {
			Descending = 1,
			Ascending = 2,
			ReleaseDescending = 3,
			ReleaseAscending = 4,
			TitleDescending = 5,
			TitleAscending = 6
		};
		enum class ListStatus {
			NotWatching = 0,
			Watching = 1,
			Plan = 2,
			Watched = 3,
			HoldOn = 4,
			Dropped = 5
		};
		enum class FriendStatus {
			NotFriends = 0,
			Friends = 1,
			SendedRequest = 2,
			RecievedRequest = 3
		};

		enum class StatsPermission {
			AllUsers = 0,
			OnlyFriends = 1,
			OnlyMe = 2,
		};
		enum class SocialPermission {
			AllUsers = 0,
			OnlyFriends = 1,
			OnlyMe = 2,
		};
		enum class ActivityPermission {
			AllUsers = 0,
			OnlyFriends = 1,
			OnlyMe = 2,
		};
		enum class FriendRequestPermission {
			AllUsers = 0,
			Nobody = 1,
		};

		ProfileID id;
		std::string username;
		std::string avatar_url;
		std::string status;
		std::string telegram_page;
		std::string vk_page;
		std::string instagram_page;
		std::string discord_page;
		std::string tt_page;
		TimestampPoint last_activity_time;
		TimestampPoint register_date;
		
		// experimental::Badge badge;

		bool is_banned;
		bool is_perm_banned;
		TimestampPoint ban_expires;
		std::string ban_reason;

		PrivilegeLevel privilege_level;
		std::chrono::minutes watched_time;
		int32_t watched_count;
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
		int32_t friend_status; // (-1) = NotFriends, (2) = Friends, (0-1) = SendedRequest or RecievedRequest
		int32_t friend_count;
		std::vector<std::shared_ptr<Release>> votes; // TODO: remove recursive definition
		std::vector<std::shared_ptr<Release>> history; // TODO: remove recursive definition
		std::vector<ProfileWatchDynamic::Ptr> watch_dynamics;
		std::vector<Role::Ptr> roles;

		bool is_blocked;
		bool is_me_blocked;
		TimestampPoint block_added_date;

		bool is_sponsor;
		TimestampPoint sponsorship_expires;

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

		FriendStatus get_friend_status_to(ProfileID other_id) const;
	};

	class EpisodeUpdate {
	public:
		using Ptr = std::shared_ptr<EpisodeUpdate>;
		EpisodeUpdate(json::CachingJsonObject& object);

		int64_t last_episode_source_update_id;
		int64_t last_episode_type_update_id;
		TimestampPoint last_episode_update_date;
		std::string last_episode_update_name;
		std::string last_episode_source_update_name;
		std::string last_episode_type_update_name;
	};

	class EpisodeSource {
	public:
		using Ptr = std::shared_ptr<EpisodeSource>;
		EpisodeSource(json::CachingJsonObject& object);

		EpisodeSourceID id;
		std::string name;
		int64_t episodes_count;
	};

	/* Типо озвучка */
	class EpisodeType {
	public:
		using Ptr = std::shared_ptr<EpisodeType>;
		EpisodeType(json::CachingJsonObject& object);

		EpisodeTypeID id;
		int64_t view_count;
		int64_t episodes_count;
		std::string name;
		std::string workers;
	};

	class Episode {
	public:
		using Ptr = std::shared_ptr<Episode>;
		Episode(json::CachingJsonObject& object);

		enum class Sort {
			FromLeast = 1,
			FromGreatest = 2
		};

		EpisodeID id;
		std::string name;
		std::string url;
		int64_t release_id;
		int64_t source_id;
		int64_t playback_position;
		int32_t position;

		bool is_watched;
		bool is_filler;
	};
	
	class ReleaseRelated {
	public:
		using Ptr = std::shared_ptr<ReleaseRelated>;

		ReleaseRelated(json::CachingJsonObject& object);

		ReleaseID id;
		std::string name;
		std::string name_ru;
		std::string description;
		std::string image_url;
		std::vector<std::string> image_urls;
		int64_t release_count;
	};

	class ReleaseVideoBanner {
	public:
		using Ptr = std::shared_ptr<ReleaseVideoBanner>;

		ReleaseVideoBanner(json::CachingJsonObject& object);

		enum class Action {
			Unknown = 0,
			Url = 1,
			VideoCategory = 2
		};

		Action action_id;
		std::string name;
		std::string image_url;
		std::string value;
		bool is_new;
	};

	class Comment {
	public:
		using Ptr = std::shared_ptr<Comment>;
		Comment(json::CachingJsonObject& object);

		static constexpr CommentID INVALID_ID = CommentID(0);

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

		CommentID id; // not sure if release CommentID and collection CommentID intersect
		CommentID parent_comment_id;
		std::string message;
		int32_t vote;
		int32_t vote_count;
		int64_t reply_count;
		TimestampPoint date;
		Profile::Ptr author;
		std::shared_ptr<Release> release; // If it's from release, this setted. TODO: remove recursive definition
		std::shared_ptr<Collection> collection; // If it's from collection, this setted. TODO: remove recursive definition

		bool is_deleted;
		bool is_edited;
		bool is_spoiler;
	};

	class Release {
	public:
		using Ptr = std::shared_ptr<Release>;
		
		Release(json::CachingJsonObject& object);

		enum class Season {
			Unknown = 0,
			Winter = 1,
			Spring = 2,
			Summer = 3,
			Fall = 4,
		};
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
		enum class AgeRating {
			Unknown = 0,
			G = 1,
			PG6 = 2,
			PG12 = 3,
			R16 = 4,
			R18 = 5
		};

		ReleaseID id;
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
		Status status; // fake field
		Category category; // fake field
		Season season;
		std::string release_date;
		TimestampPoint creation_date;
		TimestampPoint last_update_date;
		std::vector<std::string> screenshot_image_urls;
		std::vector<Release::Ptr> recomended_releases;
		std::vector<Release::Ptr> related_releases;
		ReleaseRelated::Ptr related;
		std::vector<ReleaseVideoBanner::Ptr> video_banners;
		std::vector<Comment::Ptr> comments;

		AgeRating age_rating;
		std::chrono::minutes duration;
		std::chrono::weekday broadcast; // '255' means Finished
		TimestampPoint aired_on_date;
		int32_t profile_release_type_notification_preference_count;
		int32_t vote1_count;
		int32_t vote2_count;
		int32_t vote3_count;
		int32_t vote4_count;
		int32_t vote5_count;
		int32_t vote_count;
		int32_t your_vote;
		TimestampPoint voted_date;
		int32_t my_vote;

		int32_t episodes_total;
		int64_t collection_count;
		int32_t favorite_count;
		int64_t comment_count;
		int32_t comment_per_day_count;
		int32_t watched_count;
		int32_t dropped_count;
		int32_t hold_on_count;
		int32_t plan_count;
		int32_t watching_count;

		EpisodeUpdate::Ptr episode_last_update;
		int32_t episodes_released;

		TimestampPoint last_set_completed_date;
		TimestampPoint last_set_dropped_date;
		TimestampPoint last_set_favorite_date;
		TimestampPoint last_set_hold_on_date;
		TimestampPoint last_set_plan_date;
		TimestampPoint last_set_viewed_date;
		TimestampPoint last_set_watching_date;
		TimestampPoint last_view_date;
		Episode::Ptr last_view_episode;
		// std::string last_view_episode_name; // removed. Use last_view_episode
		// std::string last_view_episode_type_name; // removed. Use last_view_episode

		std::string note;
		Profile::ListStatus profile_list_status;

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
		ReleaseVideoCategory(json::CachingJsonObject& object);

		ReleaseVideoCategoryID id;
		std::string name;
	};

	class ReleaseVideoHosting {
	public:
		using Ptr = std::shared_ptr<ReleaseVideoHosting>;
		ReleaseVideoHosting(json::CachingJsonObject& object);

		ReleaseVideoHostingID id;
		std::string name;
		std::string icon_url;
	};

	class ReleaseVideo {
	public:
		using Ptr = std::shared_ptr<ReleaseVideo>;
		ReleaseVideo(json::CachingJsonObject& object);

		ReleaseVideoID id;
		std::string title;
		std::string image_url;
		std::string url;
		std::string player_url;
		TimestampPoint date;
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
		ReleaseVideoBlock(json::CachingJsonObject& object);

		ReleaseVideoCategory::Ptr category;
		std::vector<ReleaseVideo::Ptr> videos;
	};

	class ReleaseStreamingPlatform {
	public:
		using Ptr = std::shared_ptr<ReleaseStreamingPlatform>;
		ReleaseStreamingPlatform(json::CachingJsonObject& object);

		ReleaseStreamingPlatformID id;
		std::string name;
		std::string icon_url;
		std::string url;
	};

	class ReleaseVideos {
	public:
		using Ptr = std::shared_ptr<ReleaseVideos>;
		ReleaseVideos(json::CachingJsonObject& object);

		std::vector<ReleaseVideoBlock::Ptr> blocks;
		std::vector<ReleaseVideo::Ptr> last_videos;
		std::vector<ReleaseStreamingPlatform::Ptr> streaming_platforms;
		Release::Ptr release;
	};

	class Collection {
	public:
		using Ptr = std::shared_ptr<Collection>;
		Collection(json::CachingJsonObject& object);

		enum class Sort {
			RatingLeader = 1,
			YearPopular = 2,
			SeasonPopular = 3,
			WeekPopular = 4,
			RecentlyAdded = 5,
			Random = 6
		};

		CollectionID id;
		std::string title;
		std::string description;
		Profile::Ptr creator;
		std::string image_url;
		TimestampPoint last_update_date;
		TimestampPoint creation_date;

		std::vector<Release::Ptr> releases;

		int64_t comment_count;
		int32_t favorite_count;

		bool is_favorite;
		bool is_private;
	};

	class Category {
	public:
		using Ptr = std::shared_ptr<Category>;
		Category(json::CachingJsonObject& object);

		// not implemented
	};
	class Related {
	public:
		using Ptr = std::shared_ptr<Related>;
		Related(json::CachingJsonObject& object);

		// not implemented
	};

	class Interesting {
	public:
		using Ptr = std::shared_ptr<Interesting>;
		Interesting(json::CachingJsonObject& object);

		enum class Type {
			OpenRelease = 1,
			OpenUrl = 2, // unused?
			OpenCollection = 3
		};

		InterestingID id;
		Type type;
		std::string title;
		std::string description;
		std::string image_url;
		std::string action;

		bool is_hidden;
	};

	class LoginChange {
	public:
		using Ptr = std::shared_ptr<LoginChange>;
		LoginChange(json::CachingJsonObject& object);

		LoginChangeID id;
		std::string new_login;
		TimestampPoint date;
	};

	class ProfileSocial {
	public:
		using Ptr = std::shared_ptr<ProfileSocial>;
		ProfileSocial(json::CachingJsonObject& object);

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
		ProfilePreferenceStatus(json::CachingJsonObject& object);

		TimestampPoint change_avatar_ban_expires;
		TimestampPoint change_login_ban_expires;
		bool is_change_avatar_banned;
		bool is_change_login_banned;
		bool is_google_bound;
		bool is_vk_bound;
		bool is_login_changed;
		Profile::ActivityPermission privacy_activity;
		Profile::FriendRequestPermission privacy_friend_requests;
		Profile::SocialPermission privacy_social;
		Profile::StatsPermission privacy_stats;
		std::string avatar_url;
		std::string status;
		std::string vk_page;
		std::string tg_page;
	};

	class LoginChangeInfo {
	public:
		using Ptr = std::shared_ptr<LoginChangeInfo>;
		LoginChangeInfo(json::CachingJsonObject& object);

		bool is_change_available;
		TimestampPoint last_change_date;
		TimestampPoint next_change_available_date;
		std::string login;
		std::string avatar_url;
	};

	class CollectionGetInfo {
	public:
		using Ptr = std::shared_ptr<CollectionGetInfo>;
		CollectionGetInfo(json::CachingJsonObject& object);

		Collection::Ptr collection;
		int64_t completed_count;
		int64_t dropped_count;
		int64_t hold_on_count;
		int64_t plan_count;
		int64_t watching_count;
	};
}

