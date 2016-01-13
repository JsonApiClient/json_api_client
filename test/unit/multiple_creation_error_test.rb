require 'test_helper'

class MultipleCreationErrorTest < MiniTest::Test

  class Author < TestResource
  end

  def test_create_multiple_can_handle_errors
    stub_request(:post, "http://example.com/articles")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          attributes: {
            title: "Rails is Omakase",
            category: "foo"
          }
        }, {
          type: "articles",
          attributes: {
            title: "JSON API is the bomb",
          }
        }]
      }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        errors: [{
          id: "1234-abcd",
          links: {
            about: "http://example.com/help/errors/1337"
          },
          status: "400",
          code: "1337",
          title: "Category is invalid.",
          detail: "Category 'foo' is not a valid category.",
          source: {
            pointer: "/data/1/attributes/category"
          }
        }]
      }.to_json)

    articles = Article.create([{
      title: "Rails is Omakase",
      category: "foo"
    }, {
      title: "JSON API is the bomb"
    }])

    article = articles.first
    assert !article.persisted?
    assert article.errors.present?
    assert_equal 1, article.errors.size

    error = article.last_result_set.errors.first
    assert_equal "1234-abcd", error.id
    assert_equal "http://example.com/help/errors/1337", error.about
    assert_equal "400", error.status
    assert_equal "1337", error.code
    assert_equal "Category is invalid.", error.title
    assert_equal "Category 'foo' is not a valid category.", error.detail
    assert_equal "/data/1/attributes/category", error.source_pointer
    assert_equal "category", error.source_parameter
  end
end
