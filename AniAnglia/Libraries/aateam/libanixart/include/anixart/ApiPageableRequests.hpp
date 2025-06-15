#pragma once
#include <anixart/ApiPageable.hpp>
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>
#include <anixart/ApiRequestTypes.hpp>
#include <netsess/NetTypes.hpp>

namespace anixart {
    class FilterPages : public EmptyContentPaginator<Release> {
    public:
        FilterPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::FilterRequest& request, const bool extended_mode);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        bool _extended_mode;
        requests::FilterRequest _request;
    };

    class StreamingPlatformsPages : public Paginator<ReleaseStreamingPlatform> {
    public:
        StreamingPlatformsPages(const ApiSession& session, const int32_t page, const ReleaseID release_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
    };


    class CommentsWeekPages : public Paginator<Comment> {
    public:
        CommentsWeekPages(const ApiSession& session);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
    };

    class DiscussingPages : public Paginator<Release> {
    public:
        DiscussingPages(const ApiSession& session, const std::string& token);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class InterestingPages : public Paginator<Interesting> {
    public:
        InterestingPages(const ApiSession& session);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
    };

    class RecomendationsPages : public Paginator<Release> {
    public:
        RecomendationsPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class WatchingPages : public Paginator<Release> {
    public:
        WatchingPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionSearchPages : public Paginator<Collection> {
    public:
        CollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteCollectionSearchPages : public Paginator<Collection> {
    public:
        FavoriteCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteSearchPages : public Paginator<Release> {
    public:
        FavoriteSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class HistorySearchPages : public Paginator<Release> {
    public:
        HistorySearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileCollectionSearchPages : public Paginator<Collection> {
    public:
        ProfileCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const ReleaseID release_id, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        ReleaseID _release_id;
        requests::SearchRequest _request;
    };

    class ProfileListSearchPages : public Paginator<Release> {
    public:
        ProfileListSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const Profile::ListStatus list_status, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
        Profile::ListStatus _list_status;
    };

    class ProfileSearchPages : public Paginator<Profile> {
    public:
        ProfileSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ReleaseSearchPages : public EmptyContentPaginator<Release> {
    public:
        ReleaseSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);
    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
        std::vector<Release::Ptr> parse_request() override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class LoginChangeHistoryPages : public Paginator<LoginChange> {
    public:
        LoginChangeHistoryPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class BlockListPages : public Paginator<Profile> {
    public:
        BlockListPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendsPages : public EmptyContentPaginator<Profile> {
    public:
        FriendsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class FriendRequestsInPages : public Paginator<Profile> {
    public:
        FriendRequestsInPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendRequestsOutPages : public Paginator<Profile> {
    public:
        FriendRequestsOutPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileListPages : public EmptyContentPaginator<Release> {
    public:
        ProfileListPages(const ApiSession& session, const std::string& token, const int32_t page, const Profile::ListStatus status, const Profile::ListSort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        Profile::ListStatus _tab;
        Profile::ListSort _sort;
    };

    class ProfileListByProfilePages : public EmptyContentPaginator<Release> {
    public:
        ProfileListByProfilePages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Profile::ListStatus status, const Profile::ListSort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Profile::ListStatus _tab;
        Profile::ListSort _sort;
    };

    class ProfileFavoriteReleasesPages : public EmptyContentPaginator<Release> {
    public:
        ProfileFavoriteReleasesPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Profile::ListSort sort, const int32_t filter_announce);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Profile::ListSort _sort;
        int32_t _filter_announce; // TODO: check filter_announce
    };

    class AllReleaseUnvotedPages : public Paginator<Release> {
    public:
        AllReleaseUnvotedPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileVotedReleasesPages : public EmptyContentPaginator<Release> {
    public:
        ProfileVotedReleasesPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Release::ByVoteSort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Release::ByVoteSort _sort;
    };
    
    class ReleaseRelatedPages : public EmptyContentPaginator<Release> {
    public:
        ReleaseRelatedPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseRelatedID related_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseRelatedID _related_id;
    };

    class ReleaseCommentsPages : public Paginator<Comment> {
    public:
        ReleaseCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseID release_id, const Comment::FilterBy filter_by);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseID _release_id;
        Comment::FilterBy _sort;
    };

    class ProfileReleaseCommentsPages : public Paginator<Comment> {
    public:
        ProfileReleaseCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Comment::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Comment::Sort _sort;
    };

    class ReleaseCommentRepliesPages : public OnePagePaginator<Comment> {
    public:
        ReleaseCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t page, const CommentID comment_id, const Comment::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CommentID _comment_id;
        Comment::Sort _sort;
    };

    class ReleaseVideoCategoryPages : public Paginator<ReleaseVideoCategory> {
    public:
        ReleaseVideoCategoryPages(const ApiSession& session, const int32_t page, const ReleaseID release_id, const ReleaseVideoCategoryID category_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
        int64_t _category_id;
    };

    class ProfileReleaseVideoPages : public Paginator<ReleaseVideo> {
    public:
        ProfileReleaseVideoPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class ReleaseVideoPages : public Paginator<ReleaseVideo> {
    public:
        ReleaseVideoPages(const ApiSession& session, const int32_t page, const ReleaseID release_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
    };

    class ReleaseVideoAppealPages : public Paginator<ReleaseVideo> {
    public:
        ReleaseVideoAppealPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileReleaseVideoFavoritesPages : public Paginator<ReleaseVideo> {
    public:
        ProfileReleaseVideoFavoritesPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class HistoryPages : public EmptyContentPaginator<Release> {
    public:
        HistoryPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionsPages : public EmptyContentPaginator<Collection> {
    public:
        CollectionsPages(const ApiSession& session, const std::string& token, const int32_t page, const int32_t where, const Collection::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int32_t _where;
        Collection::Sort _sort;
    };

    class ProfileCollectionsPages : public Paginator<Collection> {
    public:
        ProfileCollectionsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class ReleaseCollectionsPages : public Paginator<Collection> {
    public:
        ReleaseCollectionsPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseID release_id, const Collection::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseID _release_id;
        Collection::Sort _sort;
    };

    class CollectionReleasesPages : public EmptyContentPaginator<Release> {
    public:
        CollectionReleasesPages(const ApiSession& session, const std::string& token, const int32_t page, const CollectionID collection_id);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CollectionID _collection_id;
    };

    class CollectionCommentsPages : public Paginator<Comment> {
    public:
        CollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const CollectionID collection_id, const Comment::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CollectionID _collection_id;
        Comment::Sort _sort;
    };

    class ProfileCollectionCommentsPages : public Paginator<Comment> {
    public:
        ProfileCollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Comment::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Comment::Sort _sort;
    };

    class CollectionCommentRepliesPages : public Paginator<Comment> {
    public:
        CollectionCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t page, const CommentID comment_id, const Comment::Sort sort);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CommentID _comment_id;
        Comment::Sort _sort;
    };

    class FavoriteCollectionsPages : public Paginator<Collection> {
    public:
        FavoriteCollectionsPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        json::CachingJsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };
}

