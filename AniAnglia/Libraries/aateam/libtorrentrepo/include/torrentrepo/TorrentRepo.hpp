#pragma once
#include <torrentrepo/TorrentRepoTypes.hpp>
#include <torrentrepo/BaseError.hpp>
#include <netsess/UrlSession.hpp>

namespace torrentrepo {
	using namespace network;

	struct RepoRequestError : public RuntimeError {
		using RuntimeError::RuntimeError;
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
