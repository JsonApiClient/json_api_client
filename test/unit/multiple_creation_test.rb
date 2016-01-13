require 'test_helper'

class MultipleCreationTest < MiniTest::Test

  class Author < TestResource
  end

  def setup
    super
    stub_request(:post, "http://example.com/articles")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          attributes: {
            title: "Rails is Omakase"
          }
        }, {
          type: "articles",
          attributes: {
            title: "JSON API is the bomb"
          }
        }]
      }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }, {
          type: "articles",
          id: "2",
          attributes: {
            title: "JSON API is the bomb"
          }
        }]
      }.to_json)
  end

  def test_can_create_multiple_with_class_method
    articles = Article.create([{
      title: "Rails is Omakase"
    }, {
      title: "JSON API is the bomb"
    }])

    articles.each { |article| assert article.persisted?, article.inspect }
    assert_equal "1", articles[0].id
    assert_equal "Rails is Omakase", articles[0].title
    assert_equal "2", articles[1].id
    assert_equal "JSON API is the bomb", articles[1].title
  end

  def test_changed_attributes_empty_after_create_multiple_with_class_method
    articles = Article.create([{
      title: "Rails is Omakase"
    }, {
      title: "JSON API is the bomb"
    }])

    articles.each { |article| assert_empty article.changed_attributes }
  end
end
