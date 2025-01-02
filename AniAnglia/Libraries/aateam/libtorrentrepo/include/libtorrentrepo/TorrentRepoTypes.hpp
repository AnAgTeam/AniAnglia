#pragma once
#include <NetTypes.hpp>
#include <memory>

namespace libtorrentrepo {
	using namespace libnetwork;

	class RepoTorrentIndexFile {
	public:
		using Ptr = std::shared_ptr<RepoTorrentIndexFile>;
		RepoTorrentIndexFile(JsonObject& object);

		int64_t position;
		int64_t file_index;
	};
	class RepoTorrentIndexTypeAudio {
	public:
		using Ptr = std::shared_ptr<RepoTorrentIndexTypeAudio>;
		RepoTorrentIndexTypeAudio(JsonObject& object);

		std::string codec;
		int32_t bitrate;
		std::vector<RepoTorrentIndexFile> files;
	};
	class RepoTorrentIndexType {
	public:
		using Ptr = std::shared_ptr<RepoTorrentIndexType>;
		RepoTorrentIndexType(JsonObject& object);

		int64_t id;
		std::string name;
		std::vector<RepoTorrentIndexTypeAudio::Ptr> audios;
	};
	class RepoTorrentIndexVideo {
	public:
		using Ptr = std::shared_ptr<RepoTorrentIndexVideo>;
		RepoTorrentIndexVideo(JsonObject& object);

		int64_t resolution;
		std::vector<RepoTorrentIndexFile> files;
	};
	class RepoTorrentIndex {
	public:
		using Ptr = std::shared_ptr<RepoTorrentIndex>;
		RepoTorrentIndex(JsonObject& object);

		std::string info_hash;
		std::string magnet_url;
		std::vector<std::string> trackers;
		std::vector<RepoTorrentIndexType::Ptr> types;
		std::vector<RepoTorrentIndexVideo::Ptr> videos;
	};
};
