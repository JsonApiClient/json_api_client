require 'test_helper'

class ResourceTest < MiniTest::Test

  def test_basic
    assert_equal :id, Article.primary_key
    assert_equal "articles", Article.table_name
    assert_equal "article", Article.resource_name
  end

  def test_each_on_scope
    stub_request(:get, "http://example.com/articles")
      .with(query: {filter: {author: '5'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }]
      }.to_json)

    articles = []
    Article.where(author: '5').each do |article|
      articles.push(article)
    end
    assert_equal 1, articles.length
  end

  def test_should_always_have_type_attribute
    article = Article.new
    assert_equal "articles", article.type
    assert_equal({type: "articles"}.with_indifferent_access, article.attributes)
  end

  def test_can_set_arbitrary_attributes
    article = Article.new(asdf: "qwer")
    article.foo = "bar"
    assert_equal({type: "articles", asdf: "qwer", foo: "bar"}.with_indifferent_access, article.attributes)
  end

  def test_dynamic_attribute_methods
    article = Article.new(foo: "bar")

    assert article.respond_to? :foo
    assert article.respond_to? :foo=
    assert_equal(article.foo, "bar")

    refute article.respond_to? :bar
    assert article.respond_to? :bar=
    article.bar = "baz"
    assert article.respond_to? :bar

    assert_raises NoMethodError do
      article.quux
    end
  end

  def test_formatted_key_accessors
    with_altered_config(Article, :json_key_format => :dasherized_key) do
      article = Article.new("foo-bar" => "baz")
      # Exposed dasherized attributes as first class ruby methods and attributes
      assert_equal("baz", article.foo_bar)
      assert_equal("baz", article["foo_bar"])
    end

    with_altered_config(Article, :json_key_format => :camelized_key) do
      article = Article.new("fooBar" => "baz")
      # Exposed camelized attributes as first class ruby methods and attributes
      assert_equal("baz", article.foo_bar)
      assert_equal("baz", article["foo_bar"])
    end

    with_altered_config(Article, :json_key_format => :underscored_key) do
      article = Article.new("foo-bam" => "baz")
      # Does not recognize dasherized attributes, fall back to hash syntax
      refute article.respond_to? :foo_bam
      assert_equal("baz", article.send("foo-bam"))
      assert_equal("baz", article.send(:"foo-bam"))
      assert_equal("baz", article["foo-bam"])
      assert_equal("baz", article[:"foo-bam"])
    end
  end

  def test_associations_as_params
    article = Article.new(foo: 'bar', 'author' => {'type' => 'authors', 'id' => 1})
    assert_equal(article.foo, 'bar')
    assert_equal({'type' => 'authors', 'id' => 1}, article.relationships.author)
    assert article.relationships.attribute_changed?(:author)
  end

  def test_default_params_overrideable
    article = Article.new(type: 'Story')
    assert_equal(article.type, 'Story')
  end

end
