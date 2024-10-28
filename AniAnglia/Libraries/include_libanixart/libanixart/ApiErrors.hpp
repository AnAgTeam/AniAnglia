#pragma once
#include "ApiErrorCodes.hpp"

#include <exception>

namespace libanixart {
	class ApiError : public std::exception {
	public:
		const char* what() const noexcept override;
	};

	class ApiRequestError : public ApiError {
	public:
		ApiRequestError(int64_t code);
		const char* what() const noexcept override;

		int64_t code;
	};
	class ApiParseError : public ApiError {
	public:
		const char* what() const noexcept override;
	};

	class ApiAuthError : public ApiRequestError {
	public:
		ApiAuthError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiBookmarksError : public ApiRequestError {
	public:
		ApiBookmarksError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiCollectionError : public ApiRequestError {
	public:
		ApiCollectionError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiProfileError : public ApiRequestError {
	public:
		ApiProfileError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiReleaseError : public ApiRequestError {
	public:
		ApiReleaseError(int64_t code);
		const char* what() const noexcept override;
	};
	class ApiReportError : public ApiRequestError {
	public:
		ApiReportError(int64_t code);
		const char* what() const noexcept override;
	};

	template<typename TCode, typename TBase>
	class ApiCodeError : public TBase {
	public:
		ApiCodeError(int64_t code) : TBase(code), code(static_cast<TCode>(code)) {}
		ApiCodeError(TCode code) : TBase(static_cast<int64_t>(code)), code(code) {}
		const char* what() const noexcept override;
		int64_t get_code() const noexcept {
			return static_cast<int64_t>(code);
		}

		TCode code;
	};


	using ApiSignUpError = ApiCodeError<codes::auth::SignUpCode, ApiAuthError>;
	using ApiResendError = ApiCodeError<codes::auth::ResendCode, ApiAuthError>;
	using ApiVerifyError = ApiCodeError<codes::auth::VerifyCode, ApiAuthError>;
	using ApiSignInError = ApiCodeError<codes::auth::SignInCode, ApiAuthError>;
	using ApiRestoreError = ApiCodeError<codes::auth::RestoreCode, ApiAuthError>;
	using ApiRestoreResendError = ApiCodeError<codes::auth::RestoreResendCode, ApiAuthError>;
	using ApiRestoreVerifyError = ApiCodeError<codes::auth::RestoreVerifyCode, ApiAuthError>;
	using ApiGoogleAuthError = ApiCodeError<codes::auth::GoogleCode, ApiAuthError>;
	using ApiVkAuthError = ApiCodeError<codes::auth::VkCode, ApiAuthError>;

	using ApiBookmarksImportError = ApiCodeError<codes::bookmarks::BookmarksImportCode, ApiBookmarksError>;
	using ApiBookmarksImportStatusError = ApiCodeError<codes::bookmarks::BookmarksImportStatusCode, ApiBookmarksError>;
	using ApiBookmarksExportError = ApiCodeError<codes::bookmarks::BookmarksExportCode, ApiBookmarksError>;

	using CollectionReportError = ApiCodeError<codes::collection::CollectionReportCode, ApiCollectionError>;
	using ApiCollectionResponseError = ApiCodeError <codes::collection::CollectionResponseCode, ApiCollectionError >;
	using CreateEditCollectionError = ApiCodeError<codes::collection::CreateEditCollectionCode, ApiCollectionError>;
	using DeleteCollectionError = ApiCodeError<codes::collection::DeleteCollectionCode, ApiCollectionError>;
	using EditImageCollection = ApiCodeError<codes::collection::EditImageCollection, ApiCollectionError>;
	using FavoriteCollectionAddError = ApiCodeError<codes::collection::FavoriteCollectionAddCode, ApiCollectionError>;
	using FavoriteCollectionDeleteError = ApiCodeError<codes::collection::FavoriteCollectionDeleteCode, ApiCollectionError>;
	using ReleaseAddCollectionError = ApiCodeError<codes::collection::ReleaseAddCollectionCode, ApiCollectionError>;
	using CollectionCommentAddError = ApiCodeError<codes::collection::comment::CollectionCommentAddCode, ApiCollectionError>;
	using CollectionCommentDeleteError = ApiCodeError<codes::collection::comment::CollectionCommentDeleteCode, ApiCollectionError>;
	using CollectionCommentEditError = ApiCodeError<codes::collection::comment::CollectionCommentEditCode, ApiCollectionError>;
	using CollectionCommentReportError = ApiCodeError<codes::collection::comment::CollectionCommentReportCode, ApiCollectionError>;
	using CollectionCommentVoteError = ApiCodeError<codes::collection::comment::CollectionCommentVoteCode, ApiCollectionError>;

	using ChangeEmailConfirmError = ApiCodeError<codes::profile::ChangeEmailConfirmCode, ApiProfileError>;
	using ChangeEmailError = ApiCodeError<codes::profile::ChangeEmailCode, ApiProfileError>;
	using ChangeLoginInfoError = ApiCodeError<codes::profile::ChangeLoginInfoCode, ApiProfileError>;
	using ChangeLoginError = ApiCodeError<codes::profile::ChangeLoginCode, ApiProfileError>;
	using ChangePasswordError = ApiCodeError<codes::profile::ChangePasswordCode, ApiProfileError>;
	using GoogleBindError = ApiCodeError<codes::profile::GoogleBindCode, ApiProfileError>;
	using GoogleUnbindError = ApiCodeError<codes::profile::GoogleUnbindCode, ApiProfileError>;
	using ProfilePreferenceError = ApiCodeError<codes::profile::ProfilePreferenceCode, ApiProfileError>;
	using ProfileSocialError = ApiCodeError<codes::profile::ProfileSocialCode, ApiProfileError>;
	using RemoveFriendRequestError = ApiCodeError<codes::profile::RemoveFriendRequestCode, ApiProfileError>;
	using SendFriendRequestError = ApiCodeError<codes::profile::SendFriendRequestCode, ApiProfileError>;
	using SocialEditError = ApiCodeError<codes::profile::SocialEditCode, ApiProfileError>;
	using VkBindError = ApiCodeError<codes::profile::VkBindCode, ApiProfileError>;
	using VkUnbindError = ApiCodeError<codes::profile::VkUnbindCode, ApiProfileError>;

	using DeleteVoteReleaseError = ApiCodeError<codes::release::DeleteVoteReleaseCode, ApiReleaseError>;
	using ReleaseReportError = ApiCodeError<codes::release::ReleaseReportCode, ApiReleaseError>;
	using ReleaseError = ApiCodeError<codes::release::ReleaseCode, ApiReleaseError>;
	using VoteReleaseError = ApiCodeError<codes::release::VoteReleaseCode, ApiReleaseError>;
	using ReleaseCommentAddError = ApiCodeError<codes::release::comment::ReleaseCommentAddCode, ApiReleaseError>;
	using ReleaseCommentDeleteError = ApiCodeError<codes::release::comment::ReleaseCommentDeleteCode, ApiReleaseError>;
	using ReleaseCommentEditError = ApiCodeError<codes::release::comment::ReleaseCommentEditCode, ApiReleaseError>;
	using ReleaseCommentReportError = ApiCodeError<codes::release::comment::ReleaseCommentReportCode, ApiReleaseError>;
	using ReleaseCommentVoteError = ApiCodeError<codes::release::comment::ReleaseCommentVoteCode, ApiReleaseError>;
	using EpisodeError = ApiCodeError<codes::release::episode::EpisodeCode, ApiReleaseError>;
	using EpisodeTargetError = ApiCodeError<codes::release::episode::EpisodeTargetCode, ApiReleaseError>;
	using EpisodeUnwatchError = ApiCodeError<codes::release::episode::EpisodeUnwatchCode, ApiReleaseError>;
	using EpisodeWatchError = ApiCodeError<codes::release::episode::EpisodeWatchCode, ApiReleaseError>;
	using SourcesError = ApiCodeError<codes::release::episode::SourcesCode, ApiReleaseError>;
	using TypesError = ApiCodeError<codes::release::episode::TypesCode, ApiReleaseError>;
	using ReleaseVideosError = ApiCodeError<codes::release::video::ReleaseVideosCode, ApiReleaseError>;
	using ReleaseVideoAppealError = ApiCodeError<codes::release::video::appeal::ReleaseVideoAppealCode, ApiReleaseError>;
	using ReleaseVideoCategoriesError = ApiCodeError<codes::release::video::appeal::ReleaseVideoCategoriesCode, ApiReleaseError>;

	using ReportError = ApiCodeError<codes::report::ReportCode, ApiRequestError>;

	using PageableError = ApiCodeError<codes::PageableCode, ApiRequestError>;
}

