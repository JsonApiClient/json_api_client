require 'test_helper'

class PaginationTest < MiniTest::Test

  def test_pagination_default_number
    stub_request(:get, "http://example.com/articles?#{{page: {number: 1}}.to_query}")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        }],
        links: {
          self:  "http://example.com/articles?#{{page: {number: 1}}.to_query}",
          next:  "http://example.com/articles?#{{page: {number: 2}}.to_query}",
          prev:  nil,
          first: "http://example.com/articles?#{{page: {number: 1}}.to_query}",
          last:  "http://example.com/articles?#{{page: {number: 6}}.to_query}"
        }
      }.to_json)

    articles = Article.page(nil)
    assert_equal 1, articles.current_page
  end

end
