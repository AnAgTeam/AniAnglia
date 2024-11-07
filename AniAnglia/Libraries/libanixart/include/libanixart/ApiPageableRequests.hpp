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

    /* Api strange =). Doesn't inherit from Pageable, it's a wrapper */
    class ReleaseSearchPages {
    public:
        using PageableCode = codes::PageableCode;
        using ParseJson = json::ParseJson;

        ReleaseSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const requests::SearchRequest& request);

        std::vector<Release::Ptr> next();
        std::vector<Release::Ptr> prev();
        std::vector<Release::Ptr> go(const int32_t& page);
        std::vector<Release::Ptr> get();

        bool is_end() const;
    protected:
        JsonObject do_request(const int32_t& page) const;
    private:
        std::vector<Release::Ptr> do_parse_request();

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
        ProfileListPages(const ApiSession& session, const std::string& token, const int32_t& page, const BookmarksStatusTab& tab, const ProfileListSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        BookmarksStatusTab _tab;
        ProfileListSort _sort;
    };

    class ProfileListByProfilePages : public Pageable<Release> {
    public:
        ProfileListByProfilePages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const BookmarksStatusTab& tab, const ProfileListSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        BookmarksStatusTab _tab;
        ProfileListSort _sort;
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
        AllReleaseVotedPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const ReleaseVotedSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        ReleaseVotedSort _sort;
    };

    class ReleaseCommentsPages : public Pageable<ReleaseComment> {
    public:
        ReleaseCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& release_id, const ReleaseCommentsSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _release_id;
        ReleaseCommentsSort _sort;
    };

    class ProfileCommentsPages : public Pageable<ReleaseComment> {
    public:
        ProfileCommentsPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& profile_id, const ProfileCommentsSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _profile_id;
        ProfileCommentsSort _sort;
    };

    class ReleaseCommentRepliesPages : public Pageable<ReleaseComment> {
    public:
        ReleaseCommentRepliesPages(const ApiSession& session, const std::string& token, const int32_t& page, const int64_t& comment_id, const ReleaseCommentsSort& sort);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        int64_t _comment_id;
        ReleaseCommentsSort _sort;
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
}

