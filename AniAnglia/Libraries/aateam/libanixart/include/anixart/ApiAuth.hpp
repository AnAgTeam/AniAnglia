#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>

namespace anixart {
	class ApiAuthPending {
	public:
		using UPtr = std::unique_ptr<ApiAuthPending>;
		using Ptr = std::shared_ptr<ApiAuthPending>;

		ApiAuthPending(const ApiSession& session, const std::string& login, const std::string& email, std::string_view auth_key, const std::string& auth_value, const std::string& hash, const TimestampPoint timestamp);

		void resend();
		std::pair<Profile::Ptr, ProfileToken> verify(const std::string& email_code) const;
		bool is_expired() const;

	private:
		std::string _login;
		std::string _email;
		std::string_view _auth_key;
		std::string _auth_value;
		std::string _hash;
		TimestampPoint _timestamp;
		const ApiSession& _session;
	};

	class ApiRestorePending {
	public:
		using UPtr = std::unique_ptr<ApiRestorePending>;
		using Ptr = std::shared_ptr<ApiRestorePending>;

		ApiRestorePending(const ApiSession& session, const std::string email_or_login, const std::string& password, const std::string& hash, const TimestampPoint timestamp);

		void resend();
		std::pair<Profile::Ptr, ProfileToken> verify(const std::string& email_code) const;
		bool is_expired() const;

	private:
		std::string _login;
		std::string _email_or_login;
		std::string _password;
		std::string _hash;
		TimestampPoint _timestamp;
		const ApiSession& _session;
	};

	class ApiAuth {
	public:
		ApiAuth(const ApiSession& session);

		ApiAuthPending::UPtr sign_up(const std::string& login, const std::string& email, const std::string& password) const;
		ApiAuthPending::UPtr sign_up_google(const std::string& google_id_token) const;
		ApiAuthPending::UPtr sign_up_vk(const std::string& vk_access_token) const;

		ApiRestorePending::UPtr restore(const std::string& email_or_username, const std::string& new_password) const;

		std::pair<Profile::Ptr, ProfileToken> sign_in(const std::string& username, const std::string& password) const;
		std::pair<Profile::Ptr, ProfileToken> sign_in_google(const std::string& google_id_token) const;
		std::pair<Profile::Ptr, ProfileToken> sign_in_vk(const std::string& vk_access_token) const;

	private:
		const ApiSession& _session;
	};
}

