require 'test_helper'

class ParserTest < MiniTest::Test

  def test_can_parse_single_record
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
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

  def test_can_parse_null_data
    # Per http://jsonapi.org/format/#fetching-resources, it is sometimes
    # appropriate for an API to respond with a 200 status and null data
    # when the requested URL is one that might correspond to a single
    # resource, but doesn’t currently

    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: { title: "Rails is Omakase" },
          relationships: {
            author: {
              links: {
                related: "http://example.com/articles/1/author"
              }
            }
          }
        }
      }.to_json)

    stub_request(:get, "http://example.com/articles/1/author")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: nil
      }.to_json)

    article = Article.find(1).first
    author = article.author

    assert_nil author
  end

end
