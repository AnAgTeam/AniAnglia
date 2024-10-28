#pragma once
#include "ApiPageable.hpp"
#include "ApiSession.hpp"
#include "ApiTypes.hpp"
#include "ApiRequestTypes.hpp"

namespace libanixart {
    using types::Profile;
    using types::Release;
    using types::ReleaseComment;
    using types::ReleaseStreamingPlatform;
    using types::Interesting;
    using types::Collection;
    using requests::FilterRequest;
    using requests::SearchRequest;

    class FilterPages : public Pageable<Release> {
    public:
        FilterPages(const ApiSession& session, const FilterRequest& request, const bool& extended_mode, const std::string& token, const int32_t& page);

        FilterRequest request;

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
        CollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class FavoriteCollectionSearchPages : public Pageable<Collection> {
    public:
        FavoriteCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class FavoriteSearchPages : public Pageable<Release> {
    public:
        FavoriteSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class HistorySearchPages : public Pageable<Release> {
    public:
        HistorySearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class ProfileCollectionSearchPages : public Pageable<Collection> {
    public:
        ProfileCollectionSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class ProfileListSearchPages : public Pageable<Release> {
    public:
        ProfileListSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    class ProfileSearchPages : public Pageable<Profile> {
    public:
        ProfileSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

    protected:
        JsonObject do_request(const int32_t& page) const override;
    private:
        const ApiSession& _session;
        const std::string& _token;
        SearchRequest _request;
    };

    /* Api strange =). Doesn't inherit from Pageable, it's a wrapper */
    class ReleaseSearchPages {
    public:
        using PageableCode = codes::PageableCode;
        using ParseJson = json::ParseJson;

        ReleaseSearchPages(const ApiSession& session, const std::string& token, const int32_t& page, const SearchRequest& request);

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
        SearchRequest _request;
        int32_t _previous_page;
        int32_t _current_page;
        bool _is_end;
    };
}

