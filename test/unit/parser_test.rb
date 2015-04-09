require 'test_helper'

class TestResource < JsonApiClient::Resource
  self.site = "http://localhost:3000/"
  self.parser = JsonApiClient::Parsers::Parser
end

class Article < TestResource
end

class ParserTest < MiniTest::Unit::TestCase

  def test_can_parse_single_record
    stub_request(:get, "http://localhost:3000/articles/1.json")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: 1,
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
    assert_equal 1, article.id
    assert_equal "Rails is Omakase", article.title
  end

end