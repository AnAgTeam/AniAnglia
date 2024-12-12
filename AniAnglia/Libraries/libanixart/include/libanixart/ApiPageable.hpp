#pragma once
#include "NetTypes.hpp"
#include "JsonTools.hpp"
#include "ApiErrors.hpp"

#include <list>
#include <functional>

namespace libanixart {
	template<typename T>
	class Pageable {
	public:
		using PageableCode = codes::PageableCode;
		using ParseJson = json::ParseJson;
		using ValueType = std::shared_ptr<T>;
		using Ptr = std::shared_ptr<Pageable<T>>;
		using UniqPtr = std::unique_ptr<Pageable<T>>;

		/* call get() to initialize "_total_page_count" and "_total_count" variables */
		Pageable(const int32_t& page) :
			_previous_page(page),
			_current_page(page),
			_total_page_count(-1),
			_total_count(-1)
		{}

		virtual std::vector<ValueType> next() {
			_previous_page = _current_page;
			if (_current_page >= _total_page_count) {
				_current_page = 0;
			}
			else {
				++_current_page;
			}
			return do_parse_request();
		}
		virtual std::vector<ValueType> prev() {
			_previous_page = _current_page;
			if (_current_page <= 0) {
				_current_page = _total_page_count;
			}
			else {
				--_current_page;
			}
			return do_parse_request();
		}
		virtual std::vector<ValueType> go(const int32_t& page) {
			if (page < 0 || page > _total_page_count) {
				return {};
			}
			_previous_page = _current_page;
			_current_page = page;
			return do_parse_request();
		}
		virtual std::vector<ValueType> get() {
			return do_parse_request();
		}

		virtual int32_t get_current_page() const {
			return _current_page;
		}
		virtual bool is_end() const {
			return _current_page >= _total_page_count;
		}

	protected:
		virtual JsonObject do_request(const int32_t& page) const = 0;

		int32_t _previous_page;
		int32_t _current_page;
		int32_t _total_page_count;
		int64_t _total_count;

		virtual std::vector<ValueType> do_parse_request() {
			JsonObject resp = this->do_request(_current_page);
			assert_status_code<PageableCode, PageableError>(resp);
			_current_page = ParseJson::get<int32_t>(resp, "current_page");
			_total_page_count = ParseJson::get<int32_t>(resp, "total_page_count");
			_total_count = ParseJson::get<int64_t>(resp, "total_count");

			std::vector<ValueType> out;
			ParseJson::assign_to_objects_array(resp, "content", out);
			return out;
		}
	};
};

