#pragma once
#include <anixart/ApiErrorCodes.hpp>
#include <anixart/ApiTypes.hpp>
#include <anixart/CachingJson.hpp>
#include <netsess/JsonTools.hpp>

#include <exception>

namespace anixart {
	class ApiError : public std::exception {
	public:
		const char* what() const noexcept override;
	};

	class ApiRequestError : public ApiError {
	public:
		ApiRequestError(int64_t code);
		const char* what() const noexcept override;
		int64_t get_code() const noexcept;

		int64_t code;
	};
	class ApiParseError : public ApiError {
	public:
		const char* what() const noexcept override;
	};

	class ApiAuthRequestError : public ApiRequestError {
	public:
		ApiAuthRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiBookmarksRequestError : public ApiRequestError {
	public:
		ApiBookmarksRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiCollectionRequestError : public ApiRequestError {
	public:
		ApiCollectionRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiProfileRequestError : public ApiRequestError {
	public:
		ApiProfileRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiReleaseRequestError : public ApiRequestError {
	public:
		ApiReleaseRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiReportRequestError : public ApiRequestError {
	public:
		ApiReportRequestError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiArticleRequestError : public ApiRequestError {
	public:
		ApiArticleRequestError(int64_t code);
		const char* what() const noexcept override;
	};

	template<typename TCode, typename TBase>
	class ApiCodeError : public TBase {
	public:
		using CodeEnumType = TCode;

		ApiCodeError(int64_t code) : TBase(code), code(static_cast<TCode>(code)) {}
		ApiCodeError(TCode code) : TBase(static_cast<int64_t>(code)), code(code) {}
		const char* what() const noexcept override;

		TCode code;
	};

	using GenericAuthError = ApiCodeError<codes::GenericCode, ApiAuthRequestError>;
	using GenericBookmarksError = ApiCodeError<codes::GenericCode, ApiBookmarksRequestError>;
	using GenericCollectionError = ApiCodeError<codes::GenericCode, ApiCollectionRequestError>;
	using GenericProfileError = ApiCodeError<codes::GenericCode, ApiProfileRequestError>;
	using GenericReleaseError = ApiCodeError<codes::GenericCode, ApiReleaseRequestError>;
	using GenericRequestError = ApiCodeError<codes::GenericCode, ApiRequestError>;
	using GenericArticleError = ApiCodeError<codes::GenericCode, ApiArticleRequestError>;

	using SignUpError = ApiCodeError<codes::auth::SignUpCode, ApiAuthRequestError>;
	using ResendError = ApiCodeError<codes::auth::ResendCode, ApiAuthRequestError>;
	using VerifyError = ApiCodeError<codes::auth::VerifyCode, ApiAuthRequestError>;
	using SignInError = ApiCodeError<codes::auth::SignInCode, ApiAuthRequestError>;
	using RestoreError = ApiCodeError<codes::auth::RestoreCode, ApiAuthRequestError>;
	using RestoreResendError = ApiCodeError<codes::auth::RestoreResendCode, ApiAuthRequestError>;
	using RestoreVerifyError = ApiCodeError<codes::auth::RestoreVerifyCode, ApiAuthRequestError>;
	using GoogleAuthError = ApiCodeError<codes::auth::GoogleCode, ApiAuthRequestError>;
	using VkAuthError = ApiCodeError<codes::auth::VkCode, ApiAuthRequestError>;

	using BookmarksImportError = ApiCodeError<codes::bookmarks::BookmarksImportCode, ApiBookmarksRequestError>;
	using BookmarksImportStatusError = ApiCodeError<codes::bookmarks::BookmarksImportStatusCode, ApiBookmarksRequestError>;
	using BookmarksExportError = ApiCodeError<codes::bookmarks::BookmarksExportCode, ApiBookmarksRequestError>;

	using GetCollectionError = ApiCodeError<codes::collection::CollectionResponseCode, ApiCollectionRequestError>;
	using CreateEditCollectionError = ApiCodeError<codes::collection::CreateEditCollectionCode, ApiCollectionRequestError>;
	using RemoveCollectionError = ApiCodeError<codes::collection::RemoveCollectionCode, ApiCollectionRequestError>;
	using EditImageCollection = ApiCodeError<codes::collection::EditImageCollection, ApiCollectionRequestError>;
	using FavoriteCollectionAddError = ApiCodeError<codes::collection::FavoriteCollectionAddCode, ApiCollectionRequestError>;
	using FavoriteCollectionRemoveError = ApiCodeError<codes::collection::FavoriteCollectionRemoveCode, ApiCollectionRequestError>;
	using ReleaseAddCollectionError = ApiCodeError<codes::collection::ReleaseAddCollectionCode, ApiCollectionRequestError>;

	using ChangeEmailConfirmError = ApiCodeError<codes::profile::ChangeEmailConfirmCode, ApiProfileRequestError>;
	using ChangeEmailError = ApiCodeError<codes::profile::ChangeEmailCode, ApiProfileRequestError>;
	using ChangeLoginInfoError = ApiCodeError<codes::profile::ChangeLoginInfoCode, ApiProfileRequestError>;
	using ChangeLoginError = ApiCodeError<codes::profile::ChangeLoginCode, ApiProfileRequestError>;
	using ChangePasswordError = ApiCodeError<codes::profile::ChangePasswordCode, ApiProfileRequestError>;
	using GoogleBindError = ApiCodeError<codes::profile::GoogleBindCode, ApiProfileRequestError>;
	using GoogleUnbindError = ApiCodeError<codes::profile::GoogleUnbindCode, ApiProfileRequestError>;
	using RemoveFriendRequestError = ApiCodeError<codes::profile::RemoveFriendRequestCode, ApiProfileRequestError>;
	using SendFriendRequestError = ApiCodeError<codes::profile::SendFriendRequestCode, ApiProfileRequestError>;
	using SocialEditError = ApiCodeError<codes::profile::SocialEditCode, ApiProfileRequestError>;
	using VkBindError = ApiCodeError<codes::profile::VkBindCode, ApiProfileRequestError>;
	using VkUnbindError = ApiCodeError<codes::profile::VkUnbindCode, ApiProfileRequestError>;

	using ReleaseVideosError = ApiCodeError<codes::release::video::ReleaseVideosCode, ApiReleaseRequestError>;
	using ReleaseVideoAppealError = ApiCodeError<codes::release::video::appeal::ReleaseVideoAppealCode, ApiReleaseRequestError>;

	using ArticleError = ApiCodeError<codes::article::ArticleCode, ApiArticleRequestError>;
	using ArticleCreateEditError = ApiCodeError<codes::article::ArticleCreateEditCode, ApiArticleRequestError>;
	using ArticleRemoveError = ApiCodeError<codes::article::ArticleRemoveCode, ApiArticleRequestError>;
	using ArticleEditorAvailableError = ApiCodeError<codes::article::EditorAvailableCode, ApiArticleRequestError>;

	using ArticleSuggestionRemoveError = ApiCodeError<codes::article::suggestion::ArticleSuggestionRemoveCode, ApiArticleRequestError>;
	using ArticleSuggestionPublishError = ApiCodeError<codes::article::suggestion::ArticleSuggestionPublishCode, ApiArticleRequestError>;

	using ChannelError = ApiCodeError<codes::channel::ChannelCode, ApiArticleRequestError>;
	using BlogCreateError = ApiCodeError<codes::channel::BlogCreateCode, ApiArticleRequestError>;
	using ChannelBlockError = ApiCodeError<codes::channel::ChannelBlockCode, ApiArticleRequestError>;
	using ChannelCreateEditError = ApiCodeError<codes::channel::ChannelCreateEditCode, ApiArticleRequestError>;
	using ChannelPermissionManageError = ApiCodeError<codes::channel::PermissionManageCode, ApiArticleRequestError>;
	using ChannelSubscribeError = ApiCodeError<codes::channel::ChannelSubscribeCode, ApiArticleRequestError>;
	using ChannelUnsubscribeError = ApiCodeError<codes::channel::ChannelUnsubscribeCode, ApiArticleRequestError>;
	using ChannelUploadCoverAvatarError = ApiCodeError<codes::channel::ChannelUploadCoverAvatarCode, ApiArticleRequestError>;

	using CommentAddError = ApiCodeError<codes::comment::CommentAddCode, ApiRequestError>;
	using CommentRemoveError = ApiCodeError<codes::comment::CommentRemoveCode, ApiRequestError>;
	using CommentEditError = ApiCodeError<codes::comment::CommentEditCode, ApiRequestError>;
	using CommentVoteError = ApiCodeError<codes::comment::CommentVoteCode, ApiRequestError>;

	using ReportError = ApiCodeError<codes::report::ReportCode, ApiRequestError>;

	using PageableError = ApiCodeError<codes::PageableCode, ApiRequestError>;

	template<typename T>
		requires requires { std::derived_from<T, ApiRequestError>; typename T::CodeEnumType; }
	void assert_status_code(const int32_t& code) {
		auto code_e = static_cast<typename T::CodeEnumType>(code);
		if (code_e != T::CodeEnumType::Success) {
			throw T(code_e);
		}
	}
	template<typename T>
	void assert_status_code(network::JsonObject& object) {
		assert_status_code<T>(network::json::ParseJson::get<int32_t>(object, "code"));
	}
	template<typename T>
	void assert_status_code(json::CachingJsonObject& object) {
		assert_status_code<T>(object.get<int32_t>("code"));
	}
}

