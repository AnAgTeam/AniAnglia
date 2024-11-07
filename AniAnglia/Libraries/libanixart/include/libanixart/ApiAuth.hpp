#pragma once
#include "ApiSession.hpp"
#include "ApiTypes.hpp"

namespace libanixart {
	class ApiAuthPending {
	public:

		ApiAuthPending(const ApiSession& session, const std::string& login, const std::string& email, const std::string& password, const std::string& google_id_token, const std::string& vk_access_token, const std::string& hash, const time_point timestamp);

		void resend();
		Profile::Ptr verify(const std::string& email_code) const;
		bool is_expired() const;

	private:
		std::string _login;
		std::string _email;
		std::string _password;
		std::string _google_id_token;
		std::string _vk_access_token;
		std::string _hash;
		time_point _timestamp;
		const ApiSession& _session;
	};

	class ApiRestorePending {
	public:

		ApiRestorePending(const ApiSession& session, const std::string email_or_login, const std::string& password, const std::string& hash, const time_point timestamp);

		void resend();
		Profile::Ptr verify(const std::string& email_code) const;
		bool is_expired() const;

	private:
		std::string _login;
		std::string _email_or_login;
		std::string _password;
		std::string _hash;
		time_point _timestamp;
		const ApiSession& _session;
	};

	class ApiAuth {
	public:
		ApiAuth(const ApiSession& session);

		ApiAuthPending sign_up(const std::string& login, const std::string& email, const std::string& password) const;
		ApiAuthPending sign_up_google(const std::string& google_id_token) const;
		ApiAuthPending sign_up_vk(const std::string& vk_access_token) const;

		ApiRestorePending restore(const std::string& email_or_username, const std::string& new_password) const;

		Profile::Ptr sign_in(const std::string& username, const std::string& password) const;
		Profile::Ptr sign_in_google(const std::string& google_id_token) const;
		Profile::Ptr sign_in_vk(const std::string& vk_access_token) const;


	private:
		const ApiSession& _session;
	};
}

