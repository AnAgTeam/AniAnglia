#pragma once

namespace libanixart::codes {
	enum class GenericCode {
		Success = 0,
		Failed = 1,
		Unathorized = 401,
		Banned = 402,
		PermBanned = 403
	};
#define GENERIC_CODES	\
	Success = 0,		\
	Failed = 1,			\
	Unathorized = 401,	\
	Banned = 402,		\
	PermBanned = 403

	enum class PageableCode {
		GENERIC_CODES
	};

	namespace auth {
		enum class SignUpCode {
			GENERIC_CODES,
			InvalidLogin = 2,
			InvalidEmail = 3,
			InvalidPassword = 4,
			LoginAlreadyTaken = 5,
			EmailAlreadyTaken = 6,
			CodeAlreadySent = 7,
			CodeCannotSend = 8,
			EmailServiceDisallowed = 9,
			TooManyRegistrations = 10
		};
		enum class SignInCode {
			GENERIC_CODES,
			InvalidLogin = 2,
			InvalidPassword = 3
		};
		enum class ResendCode {
			GENERIC_CODES,
			InvalidLogin = 2,
			InvalidEmail = 3,
			InvalidPassword = 4,
			InvalidHash = 5,
			CodeCannotSend = 6
		};
		enum class VerifyCode {
			GENERIC_CODES,
			InvalidLogin = 2,
			InvalidEmail = 3,
			InvalidPassword = 4,
			LoginAlreadyTaken = 5,
			EmailAlreadyTaken = 6,
			CodeInvalid = 7,
			CodeExpired = 8,
			InvalidHash = 9,
			EmailServiceDisallowed = 10,
			TooManyRegistrations = 11
		};
		enum class RestoreCode {
			GENERIC_CODES,
			ProfileNotFound = 2,
			CodeAlreadySent = 3,
			CodeCannotSend = 4
		};
		enum class RestoreResendCode {
			Success = 0,
			Failed = 1,
			ProfileNotFound = 2,
			InvalidHash = 3,
			CodeCannotSend = 4
		};
		enum class RestoreVerifyCode {
			GENERIC_CODES,
			ProfileNotFound = 2,
			InvalidPassword = 3,
			CodeInvalid = 4,
			CodeExpired = 5,
			InvalidHash = 6
		};
		enum class GoogleCode {
			GENERIC_CODES,
			InvalidRequest = 2,
			NotRegistered = 3,
			InvalidLogin = 4,
			InvalidEmail = 5,
			LoginAlreadyTaken = 6,
			EmailAlreadyTaken = 7,
			EmailChanged = 8,
			EmailChangedAndCodeAlreadySent = 9,
			EmailServiceDisallowed = 10,
			TooManyRegistrations = 11
		};
		enum class VkCode {
			GENERIC_CODES,
			InvalidRequest = 2,
			NotRegistered = 3,
			InvalidLogin = 4,
			InvalidEmail = 5,
			LoginAlreadyTaken = 6,
			EmailAlreadyTaken = 7,
			CodeCannotSend = 8,
			EmailServiceDisallowed = 9,			
			TooManyRegistrations = 10
		};
	};
	namespace bookmarks {
		enum class BookmarksExportCode {
			GENERIC_CODES,
			INVALID_PROFILE_LISTS = 2,
			INVALID_EXTRA_FIELDS = 3
		};
		enum class BookmarksImportCode {
			GENERIC_CODES,
			IMPORT_LIMIT_REACHED = 2
		};
		enum class BookmarksImportStatusCode {
			GENERIC_CODES,
			IMPORT_LIMIT_REACHED = 2
		};
	};
	namespace collection {
		enum class CollectionReportCode {
			GENERIC_CODES,
		};
		enum class CollectionResponseCode {
			GENERIC_CODES,
			InvalidID = 2,
			IsPrivate = 3,
			IsDeleted = 4
		};
		enum class CreateEditCollectionCode {
			GENERIC_CODES,
			InvalidTitle = 2,
			InvalidDescription = 3,
			InvalidReleases = 4,
			CollectionLimitReached = 5,
			CollectionNotFound = 6,
			CollectionNotOwned = 7,
			CollectionDeleted = 8,
			ReleaseLimitReached = 9
		};
		enum class DeleteCollectionCode {
			GENERIC_CODES,
			CollectionNotFound = 2,
			CollectionNotOwned = 3
		};
		enum class EditImageCollection {
			GENERIC_CODES,
			CollectionNotFound = 2
		};
		enum class FavoriteCollectionAddCode {
			GENERIC_CODES,
			CollectionNotFound = 2,
			CollectionAlreadyInFavorite = 3
		};
		enum class FavoriteCollectionDeleteCode {
			GENERIC_CODES,
			CollectionNotFound = 2
		};
		enum class ReleaseAddCollectionCode {
			GENERIC_CODES,
			CollectionNotFound = 2,
			CollectionNotOwned = 3,
			InvalidRelease = 4,
			ReleaseAlreadyInCollection = 5,
			CollectionDeleted = 6,
			ReleaseLimitReached = 7
		};
	};
	namespace collection::comment {
		enum class CollectionCommentAddCode {
			GENERIC_CODES,
			EmbeddableNotFound = 2,
			CommentNotFound = 3,
			ProfileNotFound = 4,
			CommentIsTooShort = 5,
			CommentIsTooLong = 6,
			CommentLimitReached = 7,
			InBlocklist = 8
		};
		enum class CollectionCommentDeleteCode {
			GENERIC_CODES,
			CommentNotFound = 2,
			CommentNotOwned = 3,
		};
		enum class CollectionCommentEditCode {
			GENERIC_CODES,
			CommentNotFound = 2,
			CommentIsTooShort = 3,
			CommentIsTooLong = 4,
			CommentNotOwned = 5
		};
		enum class CollectionCommentReportCode {
			GENERIC_CODES,
		};
		enum class CollectionCommentVoteCode {
			GENERIC_CODES,
			NegativeVoteLimitReached = 2
		};
	};
	namespace profile {
		enum class ChangeEmailConfirmCode {
			GENERIC_CODES,
			InvalidPassword = 2
		};
		enum class ChangeEmailCode {
			GENERIC_CODES,
			InvalidEmail = 2,
			InvalidCurrentEmail = 3,
			EmailAlreadyTaken = 4
		};
		enum class ChangeLoginInfoCode {
			GENERIC_CODES,
		};
		enum class ChangeLoginCode {
			GENERIC_CODES,
			InvalidLogin = 2,
			LoginAlreadyTaken = 3,
			TimeLimit = 4
		};
		enum class ChangePasswordCode {
			GENERIC_CODES,
			InvalidPassword = 2,
			InvalidCurrentPassword = 3
		};
		enum class GoogleBindCode {
			GENERIC_CODES,
			InvalidRequest = 2,
			GoogleAlreadyBound = 3
		};
		enum class GoogleUnbindCode {
			GENERIC_CODES,
			GoogleNotBound = 2
		};
		enum class ProfilePreferenceCode {
			GENERIC_CODES,
		};
		enum class ProfileSocialCode {
			GENERIC_CODES,
		};
		enum class RemoveFriendRequestCode {
			GENERIC_CODES,
			RequestRemoved = 2,
			FriendshipRemoved = 3
		};
		enum class SendFriendRequestCode {
			GENERIC_CODES,
			RequestConfirmed = 2,
			RequestSent = 3,
			ProfileWasBlocked = 4,
			MyProfileWasBlocked = 5,
			FriendLimitReached = 6,
			TargetFriendLimitReached = 7,
			TargetFriendRequestDisallowed = 8
		};
		enum class SocialEditCode {
			GENERIC_CODES,
			InvalidVk = 2,
			InvalidTelegram = 3,
			InvalidInstagram = 4,
			InvalidTiktok = 5,
			InvalidDiscord = 6
		};
		enum class VkBindCode {
			GENERIC_CODES,
			InvalidRequest = 2,
			VkAlreadyBound = 3
		};
		enum class VkUnbindCode {
			GENERIC_CODES,
			VkNotBound = 2
		};
	};
	namespace release {
		enum class DeleteVoteReleaseCode {
			GENERIC_CODES,
		};
		enum class ReleaseReportCode {
			GENERIC_CODES,
		};
		enum class ReleaseCode {
			GENERIC_CODES,
		};
		enum class VoteReleaseCode {
			GENERIC_CODES,
		};
	};
	namespace release::comment {
		enum class ReleaseCommentAddCode {
			GENERIC_CODES,
			EmbeddableNotFound = 2,
			CommentNotFound = 3,
			ProfileNotFound = 4,
			CommentIsTooShort = 5,
			CommentIsTooLong = 6,
			CommentLimitReached = 7,
			InBlocklist = 8
		};
		enum class ReleaseCommentDeleteCode {
			GENERIC_CODES,
			CommentNotFound = 2,
			CommentNotOwned = 3
		};
		enum class ReleaseCommentEditCode {
			GENERIC_CODES,
			CommentNotFound = 2,
			CommentIsTooShort = 3,
			CommentIsTooLong = 4,
			CommentNotOwned = 5
		};
		enum class ReleaseCommentReportCode {
			GENERIC_CODES,
		};
		enum class ReleaseCommentVoteCode {
			GENERIC_CODES,
			NegativeVoteLimitReached = 2,
		};
	};
	namespace release::episode {
		enum class EpisodeCode {
			GENERIC_CODES,
		};
		enum class EpisodeTargetCode {
			GENERIC_CODES,
		};
		enum class EpisodeUnwatchCode {
			GENERIC_CODES,
		};
		enum class EpisodeWatchCode {
			GENERIC_CODES,
		};
		enum class SourcesCode {
			GENERIC_CODES,
		};
		enum class TypesCode {
			GENERIC_CODES,
		};
	};
	namespace release::video {
		enum class ReleaseVideosCode {
			GENERIC_CODES,
			InvalidReleaseID = 2
		};
	};
	namespace release::video::appeal {
		enum class ReleaseVideoAppealCode {
			GENERIC_CODES,
			InvalidReleaseID = 2,
			InvalidTitle = 3,
			InvalidCategory = 4,
			InvalidUrl = 5,
			AppealAlreadySent = 6,
			TooManyAppeals = 7,
			AppealNotOwned = 8,
			AppealNotFound = 9,
			AppealDisabled = 10
		};
		enum class ReleaseVideoCategoriesCode {
			GENERIC_CODES,
		};
	};
	namespace report {
		enum class ReportCode {
			GENERIC_CODES,
			EntityNotFound = 2,
			InvalidMessage = 3,
			ReasonNotFound = 4
		};
	};

#undef GENERIC_CODES
};

