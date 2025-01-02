#pragma once
#include "ApiSession.hpp"
#include "ApiPageableRequests.hpp"

namespace libanixart {
	class ApiProfiles {
	public:
		ApiProfiles(const ApiSession& session, const std::string& token);

		Profile::Ptr get_profile(const int64_t& profile_id);
		FriendsPages::UniqPtr get_friends(const int64_t& profile_id, const int32_t& start_page);
		LoginChangeHistoryPages::UniqPtr get_profile_login_history(const int64_t& profile_id, const int32_t& start_page);
		ProfileSocial::Ptr get_profile_social(const int64_t& profile_id);
		ProfileCommentsPages::UniqPtr get_profile_comments(const int64_t& profile_id, const int32_t& start_page, const ReleaseComment::Sort& sort);

		BlockListPages::UniqPtr block_list(const int32_t& start_page);
		void remove_from_block_list(const int64_t& profile_id);
		void add_to_block_list(const int64_t& profile_id);

		std::vector<Profile::Ptr> friend_recomendations();
		void hide_friend_request(const int64_t& profile_id);
		void remove_friend_request(const int64_t& profile_id);
		void send_friend_request(const int64_t& profile_id);
		FriendRequestsInPages::UniqPtr friend_requests_in(const int32_t& start_page);
		std::vector<Profile::Ptr> friend_requests_in_last();
		FriendRequestsOutPages::UniqPtr friend_requests_out(const int32_t& start_page);
		std::vector<Profile::Ptr> friend_requests_out_last();

		ProfilePreferenceStatus::Ptr edit_avatar(const std::string& image_path);
		void change_email(const std::string& current_password, const std::string& current_email, const std::string& new_email);
		void confirm_change_email(const std::string& current_password);
		void change_login(const std::string& new_login);
		LoginChangeInfo::Ptr login_change_info();
		void bind_google(const std::string& google_id_token);
		void unbind_google();
		void bind_vk(const std::string& vk_access_token);
		void unbind_vk();
		ProfilePreferenceStatus::Ptr my_preferences();
		void edit_privacy_counts(const int32_t& permission);
		void edit_privacy_friend_requests(const int32_t& permission);
		void edit_privacy_social(const int32_t& permission);
		void edit_privacy_stats(const int32_t& permission);
		ProfileSocial::Ptr social();
		void edit_social(const ProfileSocial& new_social);
		void remove_status();
		void edit_status(const std::string& new_status);

	private:
		const ApiSession& _session;
		const std::string& _token;
	};
}


