
#if defined( __APPLE__)
 #include <TargetConditionals.h>
 #define TORRENT_USE_RTC 0
  #define BOOST_ASIO_DISABLE_THREAD_KEYWORD_EXTENSION
  #define BOOST_ASIO_ENABLE_CANCELIO
  #define BOOST_ASIO_HAS_STD_CHRONO
  #define BOOST_ASIO_NO_DEPRECATED
  #define BOOST_CONTAINER_STATIC_LINK 1
  #define BOOST_JSON_STATIC_LINK 1
  #define BOOST_MULTI_INDEX_DISABLE_SERIALIZATION
  #define BOOST_NO_DEPRECATED
  #define BOOST_SYSTEM_NO_DEPRECATED
  #define BOOST_SYSTEM_STATIC_LINK 1
  #define BOOST_SYSTEM_USE_UTF8
// #define TORRENT_USE_OPENSSL 1
  #define TORRENT_ABI_VERSION 100
  #define TORRENT_BUILDING_LIBRARY
  #define TORRENT_USE_I2P 1
//  #define TORRENT_USE_GNUTLS 0
  #define _FILE_OFFSET_BITS 64
  #define _HAS_AUTO_PTR_ETC 0
  #define _SILENCE_CXX17_ALLOCATOR_VOID_DEPRECATION_WARNINGS
 #include <libtorrent/libtorrent.hpp>
#else
 #include <libtorrent/libtorrent.hpp>
#endif