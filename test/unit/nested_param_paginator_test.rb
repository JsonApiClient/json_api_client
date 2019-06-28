require 'test_helper'

class NestedParamPaginatorTest < MiniTest::Test

  class Book < JsonApiClient::Resource
    self.site = "http://example.com/"
  end

  def setup
    @nested_param_paginator = JsonApiClient::Paginating::NestedParamPaginator
    @default_paginator = JsonApiClient::Paginating::Paginator
    Article.paginator = @nested_param_paginator
  end

  def teardown
    @nested_param_paginator.page_param = @nested_param_paginator::DEFAULT_PAGE_PARAM
    @nested_param_paginator.per_page_param = @nested_param_paginator::DEFAULT_PER_PAGE_PARAM
    Article.paginator = @default_paginator
  end

  def test_default_page_params_wrapped_consistently
    assert_equal "page[page]", @nested_param_paginator.page_param
    assert_equal "page[per_page]", @nested_param_paginator.per_page_param
  end

  def test_custom_page_params_wrapped_consistently
    @nested_param_paginator.page_param = "offset"
    @nested_param_paginator.per_page_param = "limit"
    assert_equal "page[offset]", @nested_param_paginator.page_param
    assert_equal "page[limit]", @nested_param_paginator.per_page_param
  end

  def test_custom_page_param_does_not_allow_double_wrap
    assert_raises ArgumentError do
      @nested_param_paginator.page_param = "page[number]"
    end
  end

  def test_custom_per_page_param_does_not_allow_double_wrap
    assert_raises ArgumentError do
      @nested_param_paginator.per_page_param = "page[size]"
    end
  end

  def test_pagination_params_total_calculations
    @nested_param_paginator.page_param = "number"
    @nested_param_paginator.per_page_param = "size"
    stub_request(:get, "http://example.com/articles?page[number]=1&page[size]=2")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [{
                       type: "articles",
                       id: "1",
                       attributes: {
                           title: "JSON API paints my bikeshed!"
                       }
                   },
                   {
                       type: "articles",
                       id: "2",
                       attributes: {
                           title: "json_api_client counts pages correctly"
                       }
                   }],
            links: {
                self:  "http://example.com/articles?page[number]=1&page[size]=2",
                next:  "http://example.com/articles?page[number]=2&page[size]=2",
                prev:  nil,
                first: "http://example.com/articles?page[number]=1&page[size]=2",
                last:  "http://example.com/articles?page[number]=4&page[size]=2"
            }
        }.to_json)

    articles = Article.paginate(page: 1, per_page: 2).to_a
    assert_equal 1, articles.current_page
    assert_equal 4, articles.total_pages
    assert_equal 8, articles.total_entries
  ensure
    @nested_param_paginator.page_param = "page"
    @nested_param_paginator.per_page_param = "per_page"
  end

end
