require 'test_helper'

class ImplementationTest < MiniTest::Test

  def test_defaults_on_missing_fields
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }]
      }.to_json)
    articles = Article.all

    implementation = articles.implementation
    assert_equal("1.0", implementation.version)
  end

  def test_parses_json_api_implementation
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }],
        jsonapi: {
          version: "1.3",
          meta: {
            foo: "bar"
          }
        }
      }.to_json)
    articles = Article.all

    implementation = articles.implementation
    assert_equal("1.3", implementation.version)
    assert_equal("bar", implementation.meta.foo)
  end

end