#pragma once
#include <anixart/ApiPageable.hpp>
#include <anixart/ApiSession.hpp>
#include <anixart/ApiTypes.hpp>
#include <anixart/ApiRequestTypes.hpp>

namespace anixart {
    class FilterPages : public EmptyContentPaginator<Release> {
    public:
        FilterPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::FilterRequest& request, const bool extended_mode);

    protected:
        JsonObject do_request(const int32_t page) const override;
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
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
    };


    class CommentsWeekPages : public Paginator<ReleaseComment> {
    public:
        CommentsWeekPages(const ApiSession& session);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
    };

    class DiscussingPages : public Paginator<Release> {
    public:
        DiscussingPages(const ApiSession& session, const std::string& token);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class InterestingPages : public Paginator<Interesting> {
    public:
        InterestingPages(const ApiSession& session);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
    };

    class RecomendationsPages : public Paginator<Release> {
    public:
        RecomendationsPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class WatchingPages : public Paginator<Release> {
    public:
        WatchingPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionSearchPages : public Paginator<Collection> {
    public:
        CollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteCollectionSearchPages : public Paginator<Collection> {
    public:
        FavoriteCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteSearchPages : public Paginator<Release> {
    public:
        FavoriteSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class HistorySearchPages : public Paginator<Release> {
    public:
        HistorySearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileCollectionSearchPages : public Paginator<Collection> {
    public:
        ProfileCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileListSearchPages : public Paginator<Release> {
    public:
        ProfileListSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileSearchPages : public Paginator<Profile> {
    public:
        ProfileSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ReleaseSearchPages : public EmptyContentPaginator<Release> {
    public:
        ReleaseSearchPages(const ApiSession& session, const std::string& token, const int32_t page, const requests::SearchRequest& request);
    protected:
        JsonObject do_request(const int32_t page) const override;
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
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class BlockListPages : public Paginator<Profile> {
    public:
        BlockListPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendsPages : public Paginator<Profile> {
    public:
        FriendsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class FriendRequestsInPages : public Paginator<Profile> {
    public:
        FriendRequestsInPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendRequestsOutPages : public Paginator<Profile> {
    public:
        FriendRequestsOutPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileListPages : public Paginator<Release> {
    public:
        ProfileListPages(const ApiSession& session, const std::string& token, const int32_t page, const Profile::ListStatus status, const Profile::ListSort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        Profile::ListStatus _tab;
        Profile::ListSort _sort;
    };

    class ProfileListByProfilePages : public Paginator<Release> {
    public:
        ProfileListByProfilePages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Profile::ListStatus status, const Profile::ListSort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Profile::ListStatus _tab;
        Profile::ListSort _sort;
    };

    class AllReleaseUnvotedPages : public Paginator<Release> {
    public:
        AllReleaseUnvotedPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class AllReleaseVotedPages : public Paginator<Release> {
    public:
        AllReleaseVotedPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const Release::ByVoteSort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        Release::ByVoteSort _sort;
    };

    class ReleaseCommentsPages : public Paginator<ReleaseComment> {
    public:
        ReleaseCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseID release_id, const ReleaseComment::FilterBy filter_by);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseID _release_id;
        ReleaseComment::FilterBy _sort;
    };

    class ProfileCommentsPages : public Paginator<ReleaseComment> {
    public:
        ProfileCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const ReleaseComment::Sort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        ReleaseComment::Sort _sort;
    };

    class ReleaseCommentRepliesPages : public Paginator<ReleaseComment> {
    public:
        ReleaseCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseCommentID comment_id, const ReleaseComment::FilterBy filter_by);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseCommentID _comment_id;
        ReleaseComment::FilterBy _sort;
    };

    class ReleaseVideoCategoryPages : public Paginator<ReleaseVideoCategory> {
    public:
        ReleaseVideoCategoryPages(const ApiSession& session, const int32_t page, const ReleaseID release_id, const ReleaseVideoCategoryID category_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
        int64_t _category_id;
    };

    class ProfileReleaseVideoPages : public Paginator<ReleaseVideo> {
    public:
        ProfileReleaseVideoPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class ReleaseVideoPages : public Paginator<ReleaseVideo> {
    public:
        ReleaseVideoPages(const ApiSession& session, const int32_t page, const ReleaseID release_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        ReleaseID _release_id;
    };

    class ReleaseVideoAppealPages : public Paginator<ReleaseVideo> {
    public:
        ReleaseVideoAppealPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileReleaseVideoFavoritesPages : public Paginator<ReleaseVideo> {
    public:
        ProfileReleaseVideoFavoritesPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class HistoryPages : public Paginator<Release> {
    public:
        HistoryPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionsPages : public Paginator<Collection> {
    public:
        CollectionsPages(const ApiSession& session, const std::string& token, const int32_t page, const int32_t where, const Collection::Sort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
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
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
    };

    class ReleaseCollectionsPages : public Paginator<Collection> {
    public:
        ReleaseCollectionsPages(const ApiSession& session, const std::string& token, const int32_t page, const ReleaseID release_id, const Collection::Sort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ReleaseID _release_id;
        Collection::Sort _sort;
    };

    class CollectionReleasesPages : public Paginator<Release> {
    public:
        CollectionReleasesPages(const ApiSession& session, const std::string& token, const int32_t page, const CollectionID collection_id);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CollectionID _collection_id;
    };

    class CollectionCommentsPages : public Paginator<CollectionComment> {
    public:
        CollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const CollectionID collection_id, const CollectionComment::Sign sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CollectionID _collection_id;
        CollectionComment::Sign _sort;
    };

    class ProfileCollectionCommentsPages : public Paginator<CollectionComment> {
    public:
        ProfileCollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t page, const ProfileID profile_id, const CollectionComment::Sort sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileID _profile_id;
        CollectionComment::Sort _sort;
    };

    class CollectionCommentRepliesPages : public Paginator<CollectionComment> {
    public:
        CollectionCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t page, const CollectionCommentID comment_id, const CollectionComment::Sign sort);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        CollectionCommentID _comment_id;
        CollectionComment::Sign _sort;
    };

    class FavoriteCollectionsPages : public Paginator<Collection> {
    public:
        FavoriteCollectionsPages(const ApiSession& session, const std::string& token, const int32_t page);

    protected:
        JsonObject do_request(const int32_t page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };
}

