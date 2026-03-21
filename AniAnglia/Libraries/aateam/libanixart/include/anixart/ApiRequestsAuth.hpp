#pragma once
#include <anixart/ApiRequestsCoreTypes.hpp>

#include <string>
#include <string_view>

#define LIBANIXART_AUTH_PRESENTED 1

namespace anixart::requests {
	// Sources of these functions is declared in ApiRequestsAuth.cpp
	namespace auth {
		extern ApiPostRequest firebase(const std::string& token);
		extern ApiPostRequest restore(const std::string& email_or_login);
		extern ApiPostRequest restore_resend(const std::string& email_or_login, const std::string& password, const std::string& hash);
		extern ApiPostRequest restore_verify(const std::string& email_or_login, const std::string& password, const std::string& hash, const std::string& code);
		extern ApiPostRequest sign_in(const std::string& login, const std::string& password);
		extern ApiPostRequest sign_in_google(const std::string& google_id_token);
		extern ApiPostRequest sign_in_vk(const std::string& vk_access_token);
		extern ApiPostRequest sign_up(const std::string& login, const std::string& email, const std::string& password);
		extern ApiPostRequest sign_up_google(const std::string& login, const std::string& email, const std::string& google_id_token);
		extern ApiPostRequest sign_up_vk(const std::string& login, const std::string& email, const std::string& vk_access_token);
		struct AuthKeys {
			static constexpr std::string_view password = "password";
			static constexpr std::string_view google = "googleIdToken";
			static constexpr std::string_view vk = "vkAccessToken";
		};
		extern ApiPostRequest resend(const std::string& login, const std::string& email, const std::string& hash, std::string_view auth_key, const std::string& auth_value);
		extern ApiPostRequest verify(const std::string& login, const std::string& email, const std::string& hash, const std::string& code, std::string_view auth_key, const std::string& auth_value);
	};
}