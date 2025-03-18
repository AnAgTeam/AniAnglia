#pragma once
#include <torrentrepo/libtorrent_include.hpp>
#include <torrentrepo/BaseError.hpp>

#include <queue>
#include <mutex>
#include <thread>
#include <condition_variable>
#include <exception>
#include <chrono>
#include <set>
#include <atomic>

namespace torrentrepo {
	using file_index_t = lt::file_index_t;

	struct TorrentTimeoutError : public RuntimeError {
		using RuntimeError::RuntimeError;
	};

	class TorrentSession;
	class TorrentItem;

	struct TorrentFileInfo {
		std::string name;
		int64_t size;
	};

	class TorrentFile {
		friend class TorrentItem;

	public:
		TorrentFile(const TorrentItem& item, file_index_t file_index, std::streamoff offset);

		// read n bytes. If -1 reads first available piece. Blocks execution when piece is not available
		std::string read(std::streamsize n = -1);
		void seek(std::streamoff offset, std::ios::seekdir way);
		std::streamoff tell() const noexcept;
		bool eof() const noexcept;

		size_t size() const noexcept;

	private:
		void piece_recieved(const boost::shared_array<char>& buffer, std::streamsize size, lt::piece_index_t piece);

	private:
		void wait_for_piece() const;

		file_index_t _file_index;
		lt::piece_index_t _first;
		lt::piece_index_t _last;
		lt::piece_index_t _end;
		lt::piece_index_t _current;
		std::streamoff _offset;
		int _foffset;
		int _coffset;
		int _eoffset;
		int64_t _size;

		const TorrentItem& _item;
		const lt::torrent_handle& _handle;
		std::shared_ptr<const lt::torrent_info> _info;

		mutable std::mutex _sh_mutex;
		mutable std::condition_variable _sh_cv;
		lt::piece_index_t _shared_buffer_piece;
		boost::shared_array<char> _shared_buffer;
		std::streamsize _shared_buffer_size;
	};

	class TorrentItem {
		friend class TorrentSession;

		static constexpr int RETRY_COUNT = 40;

	public:
		TorrentItem(const lt::torrent_handle& handle, const lt::info_hash_t& hash);

		std::vector<TorrentFileInfo> files();
		// Start downloading pieces for "file_index". If metadata don't recieved, wait for it.
		// throws TorrentTimoutException
		std::weak_ptr<TorrentFile> start_download(const file_index_t& file_index);
		std::weak_ptr<TorrentFile> get_download(const file_index_t& file_index);

		void set_timeout(const std::chrono::system_clock::duration& timeout);

		void wait_for_metadata();

		const lt::torrent_handle& handle() const;
		lt::info_hash_t info_hash() const;

		std::atomic_bool verbose;

	private:
		void handle_alert(lt::alert* const a);

	private:

		lt::info_hash_t _info_hash;
		lt::torrent_handle _handle;
		std::chrono::high_resolution_clock::duration _timeout;
		std::vector<std::shared_ptr<TorrentFile>> _downloads;
	};

	class TorrentSession {

	public:
		TorrentSession();
		~TorrentSession();

		std::weak_ptr<TorrentItem> add_torrent(std::string_view magnet_url, std::string_view save_path, std::vector<std::string> trackers);
		std::weak_ptr<TorrentItem> get_torrent(std::string_view magnet_url);
		void remove_torrent(const std::shared_ptr<TorrentItem>& item);

		void add_default_tracker(std::string_view tracker);

	private:
		void handle_alerts();

		std::vector<std::string> _trackers;
		std::vector<std::shared_ptr<TorrentItem>> _torrent_items;
		lt::session _session;

		std::thread _alert_handle_thread;
		bool _alert_recieved;
		std::condition_variable _cv;
		std::mutex _mutex;
		bool _destructing;
	};

};

