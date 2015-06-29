require 'test_helper'

class CompoundDocumentTest < MiniTest::Test

  TEST_DATA = %{
    {
      "links": {
        "self": "http://example.com/posts",
        "next": "http://example.com/posts?page[offset]=2",
        "last": "http://example.com/posts?page[offset]=10"
      },
      "data": [{
        "type": "posts",
        "id": "1",
        "attributes": {
          "title": "JSON API paints my bikeshed!"
        },
        "relationships": {
          "author": {
            "links": {
              "self": "http://example.com/posts/1/relationships/author",
              "related": "http://example.com/posts/1/author"
            },
            "data": { "type": "people", "id": "9" }
          },
          "comments": {
            "links": {
              "self": "http://example.com/posts/1/relationships/comments",
              "related": "http://example.com/posts/1/comments"
            },
            "data": [
              { "type": "comments", "id": "5" },
              { "type": "comments", "id": "12" }
            ]
          }
        },
        "links": {
          "self": "http://example.com/posts/1"
        }
      }],
      "included": [{
        "type": "people",
        "id": "9",
        "attributes": {
          "first-name": "Dan",
          "last-name": "Gebhardt",
          "twitter": "dgeb"
        },
        "links": {
          "self": "http://example.com/people/9"
        }
      }, {
        "type": "comments",
        "id": "5",
        "attributes": {
          "body": "First!"
        },
        "links": {
          "self": "http://example.com/comments/5"
        }
      }, {
        "type": "comments",
        "id": "12",
        "attributes": {
          "body": "I like XML better"
        },
        "links": {
          "self": "http://example.com/comments/12"
        },
        "relationships": {
          "comments": {
            "links": {
              "self": "http://example.com/comments/12/relationships/comments",
              "related": "http://example.com/comments/12/comments"
            },
            "data": [
              { "type": "comments", "id": "17" },
              { "type": "comments", "id": "18" }
            ]
          }
        }
      }, {
        "type": "comments",
        "id": "17",
        "attributes": {
          "body": "XML sucks!"
        },
        "links": {
          "self": "http://example.com/comments/17"
        }
      }, {
        "type": "comments",
        "id": "18",
        "attributes": {
          "body": "Yep. XML sucks"
        },
        "links": {
          "self": "http://example.com/comments/18"
        }
      }]
    }
  }

  def test_can_handle_included_data
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: TEST_DATA)

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
    assert_equal "http://example.com/people/9", author.links.self

    comments = article.comments
    assert comments.is_a?(Array), "expected this has-many relationship to return an array"
    assert comments.all?{|comment| comment.is_a?(Comment)}, "expected this has-many relationship to return an array of Comment resources"
    assert_equal ["5", "12"], comments.map(&:id), "expected to return the comments in the order specified by the link"

    comment = comments.last
    assert_equal "I like XML better", comment.body
    assert_equal "12", comment.id
    assert_equal "http://example.com/comments/12", comment.links.self

    nested_comments = comment.comments
    assert comments.is_a?(Array), "expected this has-many relationship to return an array"
    assert comments.all?{|comment| comment.is_a?(Comment)}, "expected this has-many relationship to return an array of Comment resources"

    nested_comment = nested_comments.first
    assert_equal "XML sucks!", nested_comment.body
    assert_equal "17", nested_comment.id
    assert_equal "http://example.com/comments/17", nested_comment.links.self
  end

end
