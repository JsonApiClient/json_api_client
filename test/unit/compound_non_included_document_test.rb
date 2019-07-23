require 'test_helper'

class CompoundNonIncludedDocumentTest < MiniTest::Test

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
      }]
    }
  }

  def test_can_handle_related_data_without_included
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: TEST_DATA)

    articles = Article.all

    assert articles.is_a?(JsonApiClient::ResultSet)
    assert_equal 1, articles.length

    article = articles.first
    assert_equal "1", article.id
    assert_equal "JSON API paints my bikeshed!", article.title

    # has_one is nil if not included
    assert_nil article.author

    # has_many is empty if not included
    assert_equal 0, article.comments.size
  end
end
