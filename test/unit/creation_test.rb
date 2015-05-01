require 'test_helper'

class CreationTest < MiniTest::Unit::TestCase

  def setup
    super
    stub_request(:post, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          title: "Rails is Omakase",
          links: {
            author: {
              self: "/articles/1/links/author",
              related: "/articles/1/author",
              linkage: { type: "people", id: 9 }
            }
          }
        }
      }.to_json)
  end

  def test_can_create_with_class_method
    article = Article.create({
      title: "Rails is Omakase"
    })

    assert article.persisted?
    assert_equal "1", article.id
    assert_equal "Rails is Omakase", article.title
  end

  def test_can_create_with_new_record_and_save
    article = Article.new({
      title: "Rails is Omakase"
    })

    assert article.save
    assert article.persisted?
    assert_equal "1", article.id
  end

end
