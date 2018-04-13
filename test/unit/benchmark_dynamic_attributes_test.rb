require 'test_helper'
require 'benchmark'

class BenchmarkDynamicAttributesTest < MiniTest::Test
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

    article = Article.find(1).first

    assert_equal "Rails is Omakase", article.title
    assert_equal "1", article.id

    n = 10_000
    puts
    Benchmark.bm do |x|
      x.report('read: ') { n.times { article.title; article.id } }
      x.report('write:') do
        n.times do
          article.title = 'New title'
          article.better_title = 'Better title'
        end
      end
    end
  end
end
