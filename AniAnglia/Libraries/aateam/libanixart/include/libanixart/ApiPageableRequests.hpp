#pragma once
#include "ApiPageable.hpp"
#include "ApiSession.hpp"
#include "ApiTypes.hpp"
#include "ApiRequestTypes.hpp"

namespace libanixart {
    class FilterPages : public Pageable<Release> {
    public:
        FilterPages(const ApiSession& session, const requests::FilterRequest& request, const bool& extended_mode, const std::string& token, const int32_t& page);

        requests::FilterRequest request;

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        bool _extended_mode;
        const std::string& _token;
    };

    class StreamingPlatformsPages : public Pageable<ReleaseStreamingPlatform> {
    public:
        StreamingPlatformsPages(const ApiSession& session, const int32_t& release_id, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        int32_t _release_id;
    };


    class CommentsWeekPages : public Pageable<ReleaseComment> {
    public:
        CommentsWeekPages(const ApiSession& session);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
    };

    class DiscussingPages : public Pageable<Release> {
    public:
        DiscussingPages(const ApiSession& session, const std::string& token);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class InterestingPages : public Pageable<Interesting> {
    public:
        InterestingPages(const ApiSession& session);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
    };

    class RecomendationsPages : public Pageable<Release> {
    public:
        RecomendationsPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class WatchingPages : public Pageable<Release> {
    public:
        WatchingPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionSearchPages : public Pageable<Collection> {
    public:
        CollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteCollectionSearchPages : public Pageable<Collection> {
    public:
        FavoriteCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class FavoriteSearchPages : public Pageable<Release> {
    public:
        FavoriteSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class HistorySearchPages : public Pageable<Release> {
    public:
        HistorySearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileCollectionSearchPages : public Pageable<Collection> {
    public:
        ProfileCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileListSearchPages : public Pageable<Release> {
    public:
        ProfileListSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ProfileSearchPages : public Pageable<Profile> {
    public:
        ProfileSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
    };

    class ReleaseSearchPages : public Pageable<Release> {
    public:
        using PageableCode = codes::PageableCode;
        using ParseJson = json::ParseJson;

        ReleaseSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

        std::vector<Release::Ptr> next() override;
        std::vector<Release::Ptr> prev() override;
        std::vector<Release::Ptr> go(const int32_t& page) override;
        std::vector<Release::Ptr> get() override;

        bool is_end() const override;
    protected:
        JsonObject do_request(const int32_t& page) const;
    private:
        std::vector<Release::Ptr> do_parse_request() override;

        const ApiSession& _session;
        const std::string& _token;
        requests::SearchRequest _request;
        int32_t _previous_page;
        int32_t _current_page;
        bool _is_end;
    };

    class LoginChangeHistoryPages : public Pageable<LoginChange> {
    public:
        LoginChangeHistoryPages(const ApiSession& session, const std::string& token, const int32_t& page, const uint64_t& profile_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        uint64_t _profile_id;
    };

    class BlockListPages : public Pageable<Profile> {
    public:
        BlockListPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendsPages : public Pageable<Profile> {
    public:
        FriendsPages(const ApiSession& session, const std::string& token, const int32_t& page, const uint64_t& profile_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        uint64_t _profile_id;
    };

    class FriendRequestsInPages : public Pageable<Profile> {
    public:
        FriendRequestsInPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class FriendRequestsOutPages : public Pageable<Profile> {
    public:
        FriendRequestsOutPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileListPages : public Pageable<Release> {
    public:
        ProfileListPages(const ApiSession& session, const std::string& token, const int32_t& page, const ProfileList::Status& status, const ProfileList::Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        ProfileList::Status _tab;
        ProfileList::Sort _sort;
    };

    class ProfileListByProfilePages : public Pageable<Release> {
    public:
        ProfileListByProfilePages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const ProfileList::Status& status, const ProfileList::Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        ProfileList::Status _tab;
        ProfileList::Sort _sort;
    };

    class AllReleaseUnvotedPages : public Pageable<Release> {
    public:
        AllReleaseUnvotedPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class AllReleaseVotedPages : public Pageable<Release> {
    public:
        AllReleaseVotedPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const Release::ByVoteSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        Release::ByVoteSort _sort;
    };

    class ReleaseCommentsPages : public Pageable<ReleaseComment> {
    public:
        ReleaseCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& release_id, const ReleaseComment::FilterBy& filter_by);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _release_id;
        ReleaseComment::FilterBy _sort;
    };

    class ProfileCommentsPages : public Pageable<ReleaseComment> {
    public:
        ProfileCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const ReleaseComment::Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        ReleaseComment::Sort _sort;
    };

    class ReleaseCommentRepliesPages : public Pageable<ReleaseComment> {
    public:
        ReleaseCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& comment_id, const ReleaseComment::FilterBy& filter_by);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _comment_id;
        ReleaseComment::FilterBy _sort;
    };

    class ReleaseVideoCategoryPages : public Pageable<ReleaseVideoCategory> {
    public:
        ReleaseVideoCategoryPages(const ApiSession& session, const int32_t& page, const int64_t& release_id, const int64_t& category_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        int64_t _release_id;
        int64_t _category_id;
    };

    class ProfileReleaseVideoPages : public Pageable<ReleaseVideo> {
    public:
        ProfileReleaseVideoPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
    };

    class ReleaseVideoPages : public Pageable<ReleaseVideo> {
    public:
        ReleaseVideoPages(const ApiSession& session, const int32_t& page, const int64_t& release_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        int64_t _release_id;
    };

    class ReleaseVideoAppealPages : public Pageable<ReleaseVideo> {
    public:
        ReleaseVideoAppealPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class ProfileReleaseVideoFavoritesPages : public Pageable<ReleaseVideo> {
    public:
        ProfileReleaseVideoFavoritesPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
    };

    class HistoryPages : public Pageable<Release> {
    public:
        HistoryPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };

    class CollectionsPages : public Pageable<Collection> {
    public:
        CollectionsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int32_t& where, const Collection::Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int32_t _where;
        Collection::Sort _sort;
    };

    class ProfileCollectionsPages : public Pageable<Collection> {
    public:
        ProfileCollectionsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
    };

    class ReleaseCollectionsPages : public Pageable<Collection> {
    public:
        ReleaseCollectionsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& release_id, const Collection::Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _release_id;
        Collection::Sort _sort;
    };

    class CollectionReleasesPages : public Pageable<Release> {
    public:
        CollectionReleasesPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& collection_id);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _collection_id;
    };

    class CollectionCommentsPages : public Pageable<CollectionComment> {
    public:
        CollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& collection_id, const CollectionComment::Sign& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _collection_id;
        CollectionComment::Sign _sort;
    };

    class ProfileCollectionCommentsPages : public Pageable<CollectionComment> {
    public:
        enum Sort {
            Newest = 1,
            Oldest = 2,
            Popular = 3
        };

        ProfileCollectionCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const Sort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        Sort _sort;
    };

    class CollectionCommentRepliesPages : public Pageable<CollectionComment> {
    public:
        CollectionCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& comment_id, const CollectionComment::Sign& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _comment_id;
        CollectionComment::Sign _sort;
    };

    class FavoriteCollectionsPages : public Pageable<Collection> {
    public:
        FavoriteCollectionsPages(const ApiSession& session, const std::string& token, const int32_t& page);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
    };
}

