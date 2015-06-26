require 'test_helper'

# This tests this Resource.find method
class FindingTest < MiniTest::Test

  def test_find_by_id
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

  def test_find_by_ids
    stub_request(:get, "http://example.com/articles")
      .with(query: {ids: "2,3"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            type: "articles",
            id: "2",
            attributes: {
              title: "Rails is Omakase"
            }
          }, {
            type: "articles",
            id: "3",
            attributes: {
              title: "Foo bar"
            }
          }
        ]
      }.to_json)
    articles = Article.find([2,3])

    assert articles.is_a?(JsonApiClient::ResultSet)
    assert_equal 2, articles.length
    assert_equal ["2", "3"], articles.map(&:id)
  end

  def test_find_all
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            type: "articles",
            id: "2",
            attributes: {
              title: "Rails is Omakase"
            }
          }, {
            type: "articles",
            id: "3",
            attributes: {
              title: "Foo bar"
            }
          }
        ]
      }.to_json)
    articles = Article.all

    assert articles.is_a?(JsonApiClient::ResultSet)
    assert_equal 2, articles.length
    assert_equal ["2", "3"], articles.map(&:id)
  end

end
