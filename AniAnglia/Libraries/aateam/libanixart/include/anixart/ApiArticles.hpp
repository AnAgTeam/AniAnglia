#pragma once
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>
#include <anixart/ApiPageableRequests.hpp>
#include <filesystem>

namespace anixart {
	class ApiArticles {
	public:
		ApiArticles(const ApiSession& session, const std::string& token);

		// --- articles

		Article::Ptr get_article(const ArticleID article_id) const;
		ArticlesPages::UPtr get_articles(const requests::ArticlesFilterRequest& request, const int32_t start_page) const;
		LatestArticlesPages::UPtr get_latest_articles(const int32_t start_page) const;
		ArticleID get_latest_article_id() const;
		ArticleRepostsPages::UPtr get_article_reposts(const ArticleID article_id, const ArticleRepostsPages::Sort sort, const int32_t start_page) const;

		void vote_article(const ArticleID article_id, const int32_t vote) const;
		ArticleVotesPages::UPtr get_article_votes(const ArticleID article_id, const Profile::VoteFilterBy filter, const int32_t start_page) const;

		Article::Ptr create_article(const ChannelID channel_id, const requests::ArticleCreateEditRequest& request) const;
		Article::Ptr edit_article(const ArticleID article_id, const requests::ArticleCreateEditRequest& request) const;
		void remove_article(const ArticleID article_id) const;
		void report_article(const requests::ArticleReportRequest& request) const;

		ArticleCommentsPages::UPtr get_article_comments(const ArticleID article_id, const Comment::Sort sort, const int32_t start_page) const;
		ArticlePopularCommentsPages::UPtr get_article_popular_comments(const ArticleID article_id) const;
		ArticleCommentsByProfilePages::UPtr get_profile_article_comments(const ProfileID profile_id, const Comment::Sort sort, const int32_t start_page) const;
		ArticleCommentRepliesPages::UPtr get_article_comment_replies(const CommentID comment_id, const Comment::Sort sort, const int32_t start_page) const;
		Comment::Ptr add_article_comments(const ArticleID article_id, const requests::CommentAddRequest& request) const;
		void edit_article_comments(const CommentID comment_id, const requests::CommentEditRequest& request) const;
		void remove_article_comments(const CommentID comment_id) const;
		void report_article_comment(const requests::ArticleCommentReportRequest& request) const;
		void process_article_comment(const CommentID comment_id, const requests::CommentProcessRequest& request) const;

		Article::Ptr get_article_suggestion(const ArticleID article_suggestion_id) const;
		ArticleSuggestionsPages::UPtr get_article_suggestions(const requests::ArticleSuggestionsFilterRequest& request, const int32_t start_page) const;
		Article::Ptr create_article_suggestion(const ChannelID channel_id, const requests::ArticleSuggestionCreateEditRequest& request) const;
		Article::Ptr edit_article_suggestion(const ArticleID article_suggestion_id, const requests::ArticleSuggestionCreateEditRequest& request) const;
		void remove_article_suggestion(const ArticleID article_suggestion_id) const;
		ArticleID publish_article_suggestion(const ArticleID article_suggestion_id) const;

		ArticleCommentVotesPages::UPtr get_article_comment_votes(const CommentID comment_id, const Profile::VoteFilterBy filter, const int32_t start_page) const;
		void vote_article_comment(const CommentID comment_id, const int32_t vote) const;

		// --- channels

		Channel::Ptr get_channel(const ChannelID channel_id) const; // don't full ChannelResponse
		ChannelsPages::UPtr get_channels(const requests::ChannelsFilterRequest& request, const int32_t start_page) const; // don't full ChannelResponse
		Channel::Ptr get_blog_channel(const ProfileID profile_id) const; // don't full ChannelResponse
		Channel::Ptr create_channel(const requests::ChannelCreateEditRequest& request) const;
		Channel::Ptr edit_channel(const ChannelID channel_id, const requests::ChannelCreateEditRequest& request) const;
		Channel::Ptr create_blog_channel() const;
		std::string upload_channel_cover(const ChannelID channel_id, const std::filesystem::path& filepath) const;
		std::string upload_channel_avatar(const ChannelID channel_id, const std::filesystem::path& filepath) const;

		ChannelSubscribersPages::UPtr get_channel_subscribers(const ChannelID channel_id, const int32_t start_page) const;
		void subscribe_to_channel(const ChannelID channel_id) const;
		void unsubscribe_to_channel(const ChannelID channel_id) const;
		SubscribtionsPages::UPtr get_my_subscriptions(const int32_t start_page) const;
		int64_t get_my_subscriptions_count() const;
		ChannelRecomendationsPages::UPtr get_channel_recomendations(const int32_t start_page) const;

		ChannelPermissionsPages::UPtr get_channel_permissions(const ChannelID channel_id, const requests::ChannelPermissionsFilterRequest& request,const int32_t start_page) const;
		void edit_channel_permissions(const ChannelID channel_id, const requests::ChannelPermissionManageRequest& request) const;

		std::string get_channel_media_token(ChannelID channel_id, bool is_suggestion, bool is_edit_mode) const;

		// --- some data upload methods

		MediaFile::Ptr upload_media_file(const std::filesystem::path& filepath, const std::string& media_upload_token) const;
		ArticleEmbedBlock::Ptr upload_embed_url(const std::string& url, const std::string& media_upload_token) const;

	private:
		std::string_view get_url_service_name(std::string_view url) const;
		std::string make_authorization_header(const std::string& media_upload_token) const;

		const ApiSession& _session;
		const std::string& _token;
	};
}