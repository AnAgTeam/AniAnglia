#pragma once
#include "TorrentRepoTypes.hpp"
#include "BaseError.hpp"

#include <UrlSession.hpp>

namespace libtorrentrepo {
	using namespace libnetwork;

	struct TorrentRepoRequestError : TorrentRepoError {
		virtual const char* what() const noexcept override;
	};

	class TorrentRepo {
	public:
		static const std::string_view BASE_URL;

		TorrentRepo();

		RepoTorrentIndex get_release_index(const int64_t& release_id);

	private:
		UrlSession _session;
	};

};
