require 'test_helper'

class MetaTest < MiniTest::Test

  def test_can_parse_global_meta_data
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        },
        meta: {
          copyright: "Copyright 2015 Example Corp.",
          authors: [
            "Yehuda Katz",
            "Steve Klabnik",
            "Dan Gebhardt"
          ]
        },
      }.to_json)
    articles = Article.find(1)

    assert_equal "Copyright 2015 Example Corp.", articles.meta.copyright
    authors = articles.meta.authors
    assert_equal [
      "Yehuda Katz",
      "Steve Klabnik",
      "Dan Gebhardt"
    ], authors
  end

  def test_dasherized_meta_accessors
    with_altered_config(Article, :json_key_format => :dasherized_key) do
      stub_request(:get, "http://example.com/articles")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          data: [],
          meta: { 'record-count' => 0 },
        }.to_json)
      articles = Article.all

      # Exposed dasherized meta attributes as first class ruby methods and attributes
      assert_equal(0, articles.meta.record_count)
    end
  end

  def test_camelized_meta_accessors
    with_altered_config(Article, :json_key_format => :camelized_key) do
      stub_request(:get, "http://example.com/articles")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          data: [],
          meta: { 'recordCount' => 0 },
        }.to_json)
      articles = Article.all

      # Exposed dasherized meta attributes as first class ruby methods and attributes
      assert_equal(0, articles.meta.record_count)
    end
  end

  def test_underscored_meta_accessors
    with_altered_config(Article, :json_key_format => :underscored_key) do
      stub_request(:get, "http://example.com/articles")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          data: [],
          meta: { 'record_count' => 0 },
        }.to_json)
      articles = Article.all

      # Exposed dasherized meta attributes as first class ruby methods and attributes
      assert_equal(0, articles.meta.record_count)
    end
  end
end
