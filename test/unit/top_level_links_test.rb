require 'test_helper'

class TopLevelLinksTest < MiniTest::Test

  def test_can_parse_global_links
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        },
        links: {
          self: "http://example.com/articles/1",
          related: "http://example.com/articles/1/related"
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles/1/related")
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
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        }],
        links: {
          self: "http://example.com/articles",
          next: "http://example.com/articles?page=2",
          prev: nil,
          first: "http://example.com/articles",
          last: "http://example.com/articles?page=6"
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles?page=2")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "2",
          attributes: {
            title: "This is tha BOMB"
          }
        }],
        links: {
          self: "http://example.com/articles?page=2",
          next: "http://example.com/articles?page=3",
          prev: "http://example.com/articles",
          first: "http://example.com/articles",
          last: "http://example.com/articles?page=6"
        }
      }.to_json)

    assert_pagination
  end

  def test_can_parse_pagination_links_with_custom_config
    JsonApiClient::Paginating::Paginator.page_param = "page[number]"

    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        }],
        links: {
          self: "http://example.com/articles",
          next: "http://example.com/articles?#{{page: {number: 2}}.to_query}",
          prev: nil,
          first: "http://example.com/articles",
          last: "http://example.com/articles?#{{page: {number: 6}}.to_query}"
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles?#{{page: {number: 2}}.to_query}")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "2",
          attributes: {
            title: "This is tha BOMB"
          }
        }],
        links: {
          self: "http://example.com/articles?#{{page: {number: 2}}.to_query}",
          next: "http://example.com/articles?#{{page: {number: 3}}.to_query}",
          prev: "http://example.com/articles",
          first: "http://example.com/articles",
          last: "http://example.com/articles?#{{page: {number: 6}}.to_query}"
        }
      }.to_json)

    assert_pagination

    JsonApiClient::Paginating::Paginator.page_param = "page"
  end

  def test_can_parse_pagination_links_when_no_next_page
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        }],
        links: {
          self: "http://example.com/articles",
          prev: nil,
          first: "http://example.com/articles",
          last: "http://example.com/articles?page=1"
        }
      }.to_json)

    assert_pagination_when_no_next_page
  end

  def test_can_parse_complex_pagination_links
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          }
        }],
        links: {
          self: {
            href: "http://example.com/articles",
            meta: {}
          },
          next: {
            href: "http://example.com/articles?page=2",
            meta: {}
          },
          prev: nil,
          first: {
            href: "http://example.com/articles",
            meta: {}
          },
          last: {
            href: "http://example.com/articles?page=6",
            meta: {}
          }
        }
      }.to_json)
    stub_request(:get, "http://example.com/articles?page=2")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "2",
          attributes: {
            title: "This is tha BOMB"
          }
        }],
        links: {
          self: {
            href: "http://example.com/articles?page=2",
            meta: {}
          },
          next: {
            href: "http://example.com/articles?page=3",
            meta: {}
          },
          prev: {
            href: "http://example.com/articles",
            meta: {}
          },
          first: {
            href: "http://example.com/articles",
            meta: {}
          },
          last: {
            href: "http://example.com/articles?page=6",
            meta: {}
          }
        }
      }.to_json)

    assert_pagination
  end

  private

  def assert_pagination
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

    # test browsing to the previous page
    page1 = page2.pages.prev
    assert page1.is_a?(JsonApiClient::ResultSet)
    assert_equal 1, page1.length
    article = page1.first
    assert_equal "1", article.id
    assert_equal "JSON API paints my bikeshed!", article.title
  end

  def assert_pagination_when_no_next_page
    articles = Article.all

    # test kaminari pagination params
    assert_equal 1, articles.current_page
    assert_equal 1, articles.per_page
    assert_equal 1, articles.total_pages
    assert_equal 0, articles.offset
    assert_equal 1, articles.total_entries
    assert_equal 1, articles.limit_value
    assert_nil articles.next_page
    assert_equal 1, articles.per_page
    assert_equal false, articles.out_of_bounds?

    # test browsing to next page
    pages = articles.pages
    assert pages.respond_to?(:next)
    assert pages.respond_to?(:prev)
    assert pages.respond_to?(:last)
    assert pages.respond_to?(:first)

    page2 = articles.pages.next
    assert page2.nil?
  end
end
