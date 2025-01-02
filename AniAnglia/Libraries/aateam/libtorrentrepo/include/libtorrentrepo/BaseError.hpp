#pragma once
#include <exception>

namespace libtorrentrepo {
	struct TorrentRepoError : std::exception {
		virtual const char* what() const noexcept override;
	};
}