#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiPageableRequests.hpp>
#include <filesystem>

namespace anixart {
	class ApiProfiles {
	public:
		ApiProfiles(const ApiSession& session, const std::string& token);

		/* returns Profile and is_my_profile */
		std::pair<Profile::Ptr, bool> get_profile(const ProfileID profile_id) const;
		FriendsPages::UPtr get_friends(const ProfileID profile_id, const int32_t start_page) const;
		LoginChangeHistoryPages::UPtr get_profile_login_history(const ProfileID profile_id, const int32_t start_page) const;
		ProfileSocial::Ptr get_profile_social(const ProfileID profile_id) const;
		ProfileCommentsPages::UPtr get_profile_comments(const ProfileID profile_id, const int32_t start_page, const ReleaseComment::Sort sort) const;

		BlockListPages::UPtr block_list(const int32_t start_page) const;
		void remove_from_block_list(const ProfileID profile_id) const;
		void add_to_block_list(const ProfileID profile_id) const;

		std::vector<Profile::Ptr> friend_recomendations() const;
		void hide_friend_request(const ProfileID profile_id) const;
		void remove_friend_request(const ProfileID profile_id) const;
		void send_friend_request(const ProfileID profile_id) const;
		FriendRequestsInPages::UPtr friend_requests_in(const int32_t start_page) const;
		std::vector<Profile::Ptr> friend_requests_in_last() const;
		FriendRequestsOutPages::UPtr friend_requests_out(const int32_t start_page) const;
		std::vector<Profile::Ptr> friend_requests_out_last() const;

		// ----- MY PROFILE PREFERENCES
		ProfilePreferenceStatus::Ptr edit_avatar(const std::filesystem::path& image_path) const;
		void change_email(const std::string& current_password, const std::string& current_email, const std::string& new_email) const;
		void confirm_change_email(const std::string& current_password) const;
		std::string change_password(const std::string& current_password, const std::string& new_password) const; // return: <new token>
		void change_login(const std::string& new_login) const;
		LoginChangeInfo::Ptr login_change_info() const;
		void bind_google(const std::string& google_id_token) const;
		void unbind_google() const;
		void bind_vk(const std::string& vk_access_token) const;
		void unbind_vk() const;
		ProfilePreferenceStatus::Ptr my_preferences() const;
		void edit_privacy_activity(const Profile::ActivityPermission permission) const;
		void edit_privacy_friend_requests(const Profile::FriendRequestPermission permission) const;
		void edit_privacy_social(const Profile::SocialPermission permission) const;
		void edit_privacy_stats(const Profile::StatsPermission permission) const;
		ProfileSocial::Ptr my_social() const;
		ProfilePreferenceStatus::Ptr edit_social(const ProfileSocial::Ptr& new_social) const;
		ProfilePreferenceStatus::Ptr remove_status() const;
		ProfilePreferenceStatus::Ptr edit_status(const std::string& new_status) const;
		// -----

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}


