require 'test_helper'

class ParserTest < MiniTest::Unit::TestCase

  def test_can_parse_single_record
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          title: "Rails is Omakase",
          links: {
            author: {
              self: "/articles/1/links/author",
              related: "/articles/1/author",
              linkage: { type: "people", id: 9 }
            }
          }
        }
      }.to_json)
    articles = Article.find(1)

    assert articles.is_a?(JsonApiClient::ResultSet)
    assert_equal 1, articles.length

    article = articles.first
    assert_equal "1", article.id
    assert_equal "Rails is Omakase", article.title
  end

end
