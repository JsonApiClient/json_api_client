require 'test_helper'

class QueryBuilderTest < MiniTest::Unit::TestCase

  def test_can_specify_nested_includes
    stub_request(:get, "http://example.com/articles.json")
      .with(query: {include: "comments.author"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.includes(comments: :author).to_a
  end

  def test_can_specify_multiple_includes
    stub_request(:get, "http://example.com/articles.json")
      .with(query: {include: "comments.author,tags"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.includes({comments: :author}, :tags).to_a
  end

end