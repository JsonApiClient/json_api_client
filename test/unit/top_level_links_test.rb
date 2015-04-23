require 'test_helper'

class TopLevelLinksTest < Minitest::Unit::TestCase

  def test_can_parse_global_links
    stub_request(:get, "http://example.com/articles/1.json")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          title: "JSON API paints my bikeshed!"
        },
        links: {
          self: "http://example.com/articles/1.json",
          related: "http://example.com/articles/1/related.json"
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles/1/related.json")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "article-image",
          id: "14",
          image: "http://foo.com/cat.png"
        }
      }.to_json)

    articles = Article.find(1)
    links = articles.links
    assert links
    assert links.respond_to?(:related), "ResultSet links should respond to related"
    
    related = links.related
    assert related.is_a?(JsonApiClient::ResultSet), "expected related link to return another ResultSet"
  end

  def test_can_parse_pagination_links
    stub_request(:get, "http://example.com/articles.json")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          title: "JSON API paints my bikeshed!"
        }],
        links: {
          self: "http://example.com/articles.json",
          next: "http://example.com/articles.json?page=2",
          prev: nil,
          first: "http://example.com/articles.json",
          last: "http://example.com/articles.json?page=6"
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles.json?page=2")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "2",
          title: "This is tha BOMB"
        }],
        links: {
          self: "http://example.com/articles.json?page=2",
          next: "http://example.com/articles.json?page=3",
          prev: "http://example.com/articles.json",
          first: "http://example.com/articles.json",
          last: "http://example.com/articles.json?page=6"
        }
      }.to_json)

    articles = Article.all

    # test kaminari pagination params
    assert_equal 1, articles.current_page
    assert_equal 1, articles.per_page
    assert_equal 6, articles.total_pages
    assert_equal 0, articles.offset
    assert_equal 6, articles.total_entries
    assert_equal 1, articles.limit_value
    assert_equal 2, articles.next_page
    assert_equal 1, articles.per_page
    assert_equal false, articles.out_of_bounds?

    # test browsing to next page
    pages = articles.pages
    assert pages.respond_to?(:next)
    assert pages.respond_to?(:prev)
    assert pages.respond_to?(:last)
    assert pages.respond_to?(:first)

    page2 = articles.pages.next
    assert page2.is_a?(JsonApiClient::ResultSet)
    assert_equal 1, page2.length
    article = page2.first
    assert_equal "2", article.id
    assert_equal "This is tha BOMB", article.title
  end

end