require 'test_helper'

class MetaTest < MiniTest::Unit::TestCase

  def test_can_parse_global_meta_data
    stub_request(:get, "http://example.com/articles/1")
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

end