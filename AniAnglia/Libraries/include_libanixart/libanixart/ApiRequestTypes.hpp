#pragma once
#include "JsonTools.hpp"
#include "ApiTypes.hpp"

#include <vector>
#include <string>

namespace libanixart {
	using json::Nullable;
	using types::Episode;
	namespace requests {
		class Serializable {
		public:
			virtual std::string serialize() const = 0;
		};
		class BookmarksImportRequest {
		public:
			std::vector<int64_t> completed;
			std::vector<int64_t> dropped;
			std::vector<int64_t> hold_on;
			std::vector<int64_t> plans;
			std::vector<int64_t> watching;
			std::string selected_importer_name;
		};
		class BookmarksExportRequest {
		public:
			std::vector<int64_t> bookmarks_export_profile_lists;
		};

		class FilterRequest : Serializable {
		public:
			enum Sort {
				SortDateUpdate = 0,
				SortGrade = 1,
				SortYear = 2
			};

			std::string serialize() const override;

			Nullable<int64_t> category_id;
			Nullable<std::string> country;
			Nullable<int32_t> start_year;
			Nullable<int32_t> end_year;
			Nullable<int32_t> episode_duration_from;
			Nullable<int32_t> episode_duration_to;
			Nullable<int32_t> episodes_from;
			Nullable<int32_t> episodes_to;
			Nullable<int32_t> season;
			Nullable<int32_t> status_id;
			Nullable<std::string> studio;
			Nullable<int32_t> sort;
			bool is_genres_exclude_mode = false;
			std::vector<std::string> genres;
			std::vector<int32_t> profile_list_exclusions;
			std::vector<int64_t> types;
			std::vector<int32_t> age_ratings;
		};

		class SearchRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string query;
			int32_t search_by = 0;
		};

		class DirectLinkRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string url;
		};

		class ReleaseReportRequest : Serializable {
		public:

			std::string serialize() const override;

			std::string message;
			int64_t reason;
		};

		template<typename T>
		class ReportRequest : Serializable {
		public:
			typedef std::shared_ptr<T> TTypePtr;

			std::string serialize() const override {
                // not implemented
				throw std::exception();
			}

			TTypePtr entity;
			std::string message;
			int64_t reason;
		};
		using EpisodeReportRequest = ReportRequest<Episode>;
	}
}
