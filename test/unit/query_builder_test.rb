require 'test_helper'

class QueryBuilderTest < MiniTest::Test

  def test_can_filter
    stub_request(:get, "http://example.com/articles")
      .with(query: {filter: {author: '5'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.where(author: '5').to_a
  end

  def test_can_specify_nested_includes
    stub_request(:get, "http://example.com/articles")
      .with(query: {include: "comments.author"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.includes(comments: :author).to_a
  end

  def test_can_specify_multiple_includes
    stub_request(:get, "http://example.com/articles")
      .with(query: {include: "comments.author,tags"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.includes({comments: :author}, :tags).to_a
  end

  def test_can_paginate
    stub_request(:get, "http://example.com/articles")
      .with(query: {page: {number: 3, size: 6}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.paginate(page: 3, per_page: 6).to_a
  end

  def test_can_sort_asc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    Article.order(foo: :asc).to_a
  end

  def test_sort_defaults_to_asc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    Article.order(:foo).to_a
  end

  def test_can_sort_desc
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    Article.order(foo: :desc).to_a
  end

  def test_can_sort_multiple
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo,bar"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.order(foo: :desc, bar: :asc).to_a
  end

  def test_can_sort_mixed
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "-foo,bar"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.order(foo: :desc).order(:bar).to_a
  end

  def test_can_specify_additional_params
    stub_request(:get, "http://example.com/articles")
      .with(query: {sort: "foo"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    Article.with_params(sort: "foo").to_a
  end

  def test_can_select_fields
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'title,body'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select("title,body").to_a
  end

  def test_can_select_fields_using_array_of_strings
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'title,body'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select(["title", "body"]).to_a
  end

  def test_can_select_fields_using_array_of_symbols
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'title,body'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select([:title, :body]).to_a
  end

  def test_can_select_fields_using_implicit_array
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'title,body'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select(:title, :body).to_a
  end

end
