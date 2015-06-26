require 'test_helper'

class CompoundDocumentTest < MiniTest::Test

  def test_can_handle_included_data
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          },
          links: {
            self: "http://example.com/articles/1"
          },
          relationships: {
            author: {
              self: "http://example.com/articles/1/links/author",
              related: "http://example.com/articles/1/author",
              data: { type: "people", id: "9" }
            },
            comments: {
              self: "http://example.com/articles/1/links/comments",
              related: "http://example.com/articles/1/comments",
              data: [
                { type: "comments", id: "5" },
                { type: "comments", id: "12" }
              ]
            }
          }
        }],
        included: [{
          type: "people",
          id: "9",
          attributes: {
            "first-name" => "Dan",
            "last-name" => "Gebhardt",
            twitter: "dgeb"
          },
          links: {
            self: "http://example.com/people/9"
          }
        }, {
          type: "comments",
          id: "5",
          attributes: {
            body: "First!"
          },
          links: {
            self: "http://example.com/comments/5"
          }
        }, {
          type: "comments",
          id: "12",
          attributes: {
            body: "I like XML better"
          },
          links: {
            self: "http://example.com/comments/12"
          }
        }]
      }.to_json)

    articles = Article.all

    assert articles.is_a?(JsonApiClient::ResultSet)
    assert_equal 1, articles.length

    article = articles.first
    assert_equal "1", article.id
    assert_equal "JSON API paints my bikeshed!", article.title

    author = article.author
    assert author.is_a?(Person), "expected this has-one relation to return a single Person resource"
    assert_equal "Dan", author["first-name"]
    assert_equal "Gebhardt", author["last-name"]
    assert_equal "dgeb", author.twitter

    comments = article.comments
    assert comments.is_a?(Array), "expected this has-many relationship to return an array"
    assert comments.all?{|comment| comment.is_a?(Comment)}, "expected this has-many relationship to return an array of Comment resources"

    assert_equal ["5", "12"], comments.map(&:id), "expected to return the comments in the order specified by the link"
    comment = comments.first

    assert_equal "First!", comment.body
    assert_equal "5", comment.id
  end

end
