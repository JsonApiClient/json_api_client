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
      .with(query: {page: {page: 3, per_page: 6}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.paginate(page: 3, per_page: 6).to_a
  end

  def test_pagination_default_number
    JsonApiClient::Paginating::Paginator.page_param = :number
    stub_request(:get, "http://example.com/articles?#{{page: {number: 1}}.to_query}")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [{
                       type: "articles",
                       id: "1",
                       attributes: {
                           title: "JSON API paints my bikeshed!"
                       }
                   }],
            links: {
                self:  "http://example.com/articles?#{{page: {number: 1}}.to_query}",
                next:  "http://example.com/articles?#{{page: {number: 2}}.to_query}",
                prev:  nil,
                first: "http://example.com/articles?#{{page: {number: 1}}.to_query}",
                last:  "http://example.com/articles?#{{page: {number: 6}}.to_query}"
            }
        }.to_json)

    articles = Article.page(nil)
    assert_equal 1, articles.current_page
  ensure
    JsonApiClient::Paginating::Paginator.page_param = :page
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

  def test_can_select_nested_fields_using_hashes
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'tags', comments: 'author'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select({comments: :author}, :tags).to_a
  end


  def test_can_select_nested_fields_using_hashes_of_arrays
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'tags', comments: 'author,text'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select({comments: [:author, :text]}, :tags).to_a
  end

  def test_can_select_nested_fields_using_strings
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'tags', comments: 'author,text'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select({comments: ['author', 'text']}, :tags).to_a
  end

  def test_can_select_nested_fields_using_comma_separated_strings
    stub_request(:get, "http://example.com/articles")
      .with(query: {fields: {articles: 'tags', comments: 'author,text'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)
    Article.select({comments: 'author,text'}, :tags).to_a
  end

  def test_can_specify_array_filter_value
    stub_request(:get, "http://example.com/articles?filter%5Bauthor.id%5D%5B0%5D=foo&filter%5Bauthor.id%5D%5B1%5D=bar")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: []
        }.to_json)
    Article.where(:'author.id' => ['foo', 'bar']).to_a
  end

  def test_can_specify_empty_array_filter_value
    stub_request(:get, "http://example.com/articles?filter%5Bauthor.id%5D%5B0%5D")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: []
        }.to_json)
    Article.where(:'author.id' => []).to_a
  end

  def test_can_specify_empty_string_filter_value
    stub_request(:get, "http://example.com/articles")
        .with(query: {filter: {:'author.id' => ''}})
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: []
        }.to_json)
    Article.where(:'author.id' => '').to_a
  end

  def test_scopes_are_nondestructive
    first_stub = stub_request(:get, "http://example.com/articles?page[page]=1&page[per_page]=1")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    all_stub = stub_request(:get, "http://example.com/articles")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    scope = Article.where()

    scope.first
    scope.all

    assert_requested first_stub, times: 1
    assert_requested all_stub, times: 1
  end

  def test_find_with_args
    first_stub = stub_request(:get, "http://example.com/articles?filter[author.id]=foo")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    all_stub = stub_request(:get, "http://example.com/articles")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    find_stub = stub_request(:get, "http://example.com/articles/6")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    scope = Article.where()

    scope.find( "author.id" => "foo" )
    scope.find(6)
    scope.all

    assert_requested first_stub, times: 1
    assert_requested all_stub, times: 1
    assert_requested find_stub, times: 1
  end

  def test_find_with_blank_args
    blank_params = [nil, '', {}]

    with_altered_config(Article, :raise_on_blank_find_param => true) do
      blank_params.each do |blank_param|
        assert_raises JsonApiClient::Errors::NotFound do
          Article.find(blank_param)
        end
      end
    end

    # `.find('')` hits the INDEX URL with trailing slash, the others without one..
    collection_stub = stub_request(:get, %r{\Ahttp://example.com/articles/?\z})
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    blank_params.each do |blank_param|
      Article.find(blank_param)
    end

    assert_requested collection_stub, times: 3
  end

  def test_all_on_blank_raising_resource
    with_altered_config(Article, :raise_on_blank_find_param => true) do
      all_stub = stub_request(:get, "http://example.com/articles")
          .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

      Article.all

      assert_requested all_stub, times: 1
    end
  end

  def test_build_does_not_propagate_values
    query = Article.where(name: 'John').
        includes(:author).
        order(id: :desc).
        select(:id, :name).
        page(1).
        per(20).
        with_params(sort: "foo")

    record = query.build
    assert_equal [], record.changed
    assert_equal [], record.relationships.changed
  end

  def test_build_propagate_only_path_params
    query = ArticleNested.where(author_id: '123', name: 'John')
    record = query.build
    assert_equal [], record.changed
    assert_equal({author_id: '123'}, record.__belongs_to_params)
    assert_equal '123', record.author_id
    assert_equal [], record.relationships.changed
  end

  def test_build_hash_sum
    a = ArticleNested.where(author_id: '123', name: 'John')
    b = ArticleNested.where(author_id: '123', name: 'John')
    c = ArticleNested.where(author_id: '123')
    d = Article.where(author_id: '123', name: 'John')
    assert(a.hash == b.hash)
    assert_equal(false, a.hash == c.hash)
    assert_equal(false, a.hash == d.hash)
  end

  def test_build_eql
    a = ArticleNested.where(author_id: '123', name: 'John')
    b = ArticleNested.where(author_id: '123', name: 'John')
    c = ArticleNested.where(author_id: '123')
    d = Article.where(author_id: '123', name: 'John')
    assert(a == b)
    assert_equal(false, a == c)
    assert_equal(false, a == d)
  end
end
