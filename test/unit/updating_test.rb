require 'test_helper'

class UpdatingTest < MiniTest::Unit::TestCase

  def setup
    super
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
  end

  def test_can_update_found_record
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            attributes: {
              title: "Modified title",
              foo: "bar"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Modified title",
            foo: "bar"
          }
        }
      }.to_json)

    article.title = "Modified title"
    article.foo = "bar"
    assert article.save
  end

  def test_can_update_found_record_in_bulk
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            attributes: {
              title: "Modified title",
              foo: "bar"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          id: "1",
          type: "articles",
          attirbutes: {
            title: "Modified title",
            foo: "bar"
          }
        }
      }.to_json)

    assert article.update_attributes({
      title: "Modified title",
      foo: "bar"
    })
  end

  def test_can_update_links
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            links: {
              author: {
                linkage: {
                  type: "people",
                  id: "1"
                }
              }
            },
            attributes: {
              title: "Rails is Omakase"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          },
          links: {
            author: {
              self: "/articles/1/links/author",
              related: "/articles/1/author",
              linkage: { type: "people", id: "1" }
            }
          }
        }
      }.to_json)

    article.links.author = Person.new(id: "1")
    assert article.save
  end

  def test_can_update_has_many_links
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            links: {
              comments: {
                linkage: [{
                  type: "comments",
                  id: "2"
                },{
                  type: "comments",
                  id: "3"
                }]
              }
            },
            attributes: {
              title: "Rails is Omakase"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          id: "1",
          type: "articles",
          links: {
            author: {
              self: "/articles/1/links/author",
              related: "/articles/1/author",
              linkage: { type: "people", id: "1" }
            }
          },
          attributes: {
            title: "Rails is Omakase"
          }
        }
      }.to_json)

    article.links.comments = [
      Comment.new(id: "2"),
      Comment.new(id: "3")
    ]
    assert article.save
  end

end
