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
	using CollectionReportError = ApiCodeError<codes::collection::CollectionReportCode, ApiCollectionRequestError>;
	using CreateEditCollectionError = ApiCodeError<codes::collection::CreateEditCollectionCode, ApiCollectionRequestError>;
	using RemoveCollectionError = ApiCodeError<codes::collection::RemoveCollectionCode, ApiCollectionRequestError>;
	using EditImageCollection = ApiCodeError<codes::collection::EditImageCollection, ApiCollectionRequestError>;
	using FavoriteCollectionAddError = ApiCodeError<codes::collection::FavoriteCollectionAddCode, ApiCollectionRequestError>;
	using FavoriteCollectionRemoveError = ApiCodeError<codes::collection::FavoriteCollectionRemoveCode, ApiCollectionRequestError>;
	using ReleaseAddCollectionError = ApiCodeError<codes::collection::ReleaseAddCollectionCode, ApiCollectionRequestError>;
	using CollectionCommentAddError = ApiCodeError<codes::collection::comment::CollectionCommentAddCode, ApiCollectionRequestError>;
	using CollectionCommentRemoveError = ApiCodeError<codes::collection::comment::CollectionCommentRemoveCode, ApiCollectionRequestError>;
	using CollectionCommentEditError = ApiCodeError<codes::collection::comment::CollectionCommentEditCode, ApiCollectionRequestError>;
	using CollectionCommentReportError = ApiCodeError<codes::collection::comment::CollectionCommentReportCode, ApiCollectionRequestError>;
	using CollectionCommentVoteError = ApiCodeError<codes::collection::comment::CollectionCommentVoteCode, ApiCollectionRequestError>;

	using ChangeEmailConfirmError = ApiCodeError<codes::profile::ChangeEmailConfirmCode, ApiProfileRequestError>;
	using ChangeEmailError = ApiCodeError<codes::profile::ChangeEmailCode, ApiProfileRequestError>;
	using ChangeLoginInfoError = ApiCodeError<codes::profile::ChangeLoginInfoCode, ApiProfileRequestError>;
	using ChangeLoginError = ApiCodeError<codes::profile::ChangeLoginCode, ApiProfileRequestError>;
	using ChangePasswordError = ApiCodeError<codes::profile::ChangePasswordCode, ApiProfileRequestError>;
	using GoogleBindError = ApiCodeError<codes::profile::GoogleBindCode, ApiProfileRequestError>;
	using GoogleUnbindError = ApiCodeError<codes::profile::GoogleUnbindCode, ApiProfileRequestError>;
	using ProfilePreferenceError = ApiCodeError<codes::profile::ProfilePreferenceCode, ApiProfileRequestError>;
	using ProfileSocialError = ApiCodeError<codes::profile::ProfileSocialCode, ApiProfileRequestError>;
	using RemoveFriendRequestError = ApiCodeError<codes::profile::RemoveFriendRequestCode, ApiProfileRequestError>;
	using SendFriendRequestError = ApiCodeError<codes::profile::SendFriendRequestCode, ApiProfileRequestError>;
	using SocialEditError = ApiCodeError<codes::profile::SocialEditCode, ApiProfileRequestError>;
	using VkBindError = ApiCodeError<codes::profile::VkBindCode, ApiProfileRequestError>;
	using VkUnbindError = ApiCodeError<codes::profile::VkUnbindCode, ApiProfileRequestError>;
	using AddToBlockListError = ApiCodeError<codes::profile::AddToBlockListCode, ApiProfileRequestError>;
	using RemoveFromBlockListError = ApiCodeError<codes::profile::RemoveFromBlockListCode, ApiProfileRequestError>;

	using RemoveVoteReleaseError = ApiCodeError<codes::release::RemoveVoteReleaseCode, ApiReleaseRequestError>;
	using ReleaseReportError = ApiCodeError<codes::release::ReleaseReportCode, ApiReleaseRequestError>;
	using ReleaseError = ApiCodeError<codes::release::ReleaseCode, ApiReleaseRequestError>;
	using VoteReleaseError = ApiCodeError<codes::release::VoteReleaseCode, ApiReleaseRequestError>;
	using ReleaseCommentAddError = ApiCodeError<codes::release::comment::ReleaseCommentAddCode, ApiReleaseRequestError>;
	using ReleaseCommentRemoveError = ApiCodeError<codes::release::comment::ReleaseCommentRemoveCode, ApiReleaseRequestError>;
	using ReleaseCommentEditError = ApiCodeError<codes::release::comment::ReleaseCommentEditCode, ApiReleaseRequestError>;
	using ReleaseCommentReportError = ApiCodeError<codes::release::comment::ReleaseCommentReportCode, ApiReleaseRequestError>;
	using ReleaseCommentVoteError = ApiCodeError<codes::release::comment::ReleaseCommentVoteCode, ApiReleaseRequestError>;
	using EpisodeError = ApiCodeError<codes::release::episode::EpisodeCode, ApiReleaseRequestError>;
	using EpisodeTargetError = ApiCodeError<codes::release::episode::EpisodeTargetCode, ApiReleaseRequestError>;
	using EpisodeUnwatchError = ApiCodeError<codes::release::episode::EpisodeUnwatchCode, ApiReleaseRequestError>;
	using EpisodeWatchError = ApiCodeError<codes::release::episode::EpisodeWatchCode, ApiReleaseRequestError>;
	using SourcesError = ApiCodeError<codes::release::episode::SourcesCode, ApiReleaseRequestError>;
	using TypesError = ApiCodeError<codes::release::episode::TypesCode, ApiReleaseRequestError>;
	using ReleaseVideosError = ApiCodeError<codes::release::video::ReleaseVideosCode, ApiReleaseRequestError>;
	using ReleaseVideoAppealError = ApiCodeError<codes::release::video::appeal::ReleaseVideoAppealCode, ApiReleaseRequestError>;
	using ReleaseVideoCategoriesError = ApiCodeError<codes::release::video::appeal::ReleaseVideoCategoriesCode, ApiReleaseRequestError>;

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

