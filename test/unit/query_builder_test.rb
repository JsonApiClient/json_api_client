require 'test_helper'

class QueryBuilderTest < MiniTest::Unit::TestCase

  def test_can_filter
    stub_request(:get, "http://example.com/articles")
      .with(query: {filter: {author: '5'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.where(author: '5').to_a
  end

  def test_can_specify_nested_includes
    stub_request(:get, "http://example.com/articles")
      .with(query: {include: "comments.author"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.includes(comments: :author).to_a
  end

  def test_can_specify_multiple_includes
    stub_request(:get, "http://example.com/articles")
      .with(query: {include: "comments.author,tags"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.includes({comments: :author}, :tags).to_a
  end

  def test_can_paginate
    stub_request(:get, "http://example.com/articles")
      .with(query: {page: 3, per_page: 6})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.paginate(page: 3, per_page: 6).to_a
  end

  def test_can_sort_asc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "+foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    articles = Article.order(foo: :asc).to_a
  end

  def test_sort_defaults_to_asc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "+foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    articles = Article.order(:foo).to_a
  end

  def test_can_sort_desc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    articles = Article.order(foo: :desc).to_a
  end

  def test_can_sort_multiple
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo,+bar"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.order(foo: :desc, bar: :asc).to_a
  end

  def test_can_sort_mixed
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo,+bar"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.order(foo: :desc).order(:bar).to_a
  end

  def test_can_select_fields
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'title,body'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    articles = Article.select("title,body").to_a
  end

end
