require 'test_helper'

class SerializingTest < MiniTest::Test

  class LimitedField < TestResource
    self.read_only_attributes += ['foo']
  end

  class NestedResource < TestResource
    belongs_to :bar
  end

  class CustomSerializerAttributes < TestResource

    protected

    def attributes_for_serialization
      {
        foo: "bar"
      }
    end
  end

  class InheritedCustomSerializerAttributes < TestResource

    protected

    def attributes_for_serialization
      super.except(:foo)
    end
  end

  def test_as_json
    expected = {
      'type' => 'articles',
      'id' => '1',
      'attributes' => {
        'title' => 'Rails is Omakase'
      }
    }
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }]
      }.to_json)
    resource = Article.find(1)
    assert_equal expected, resource.first.as_json
  end

  def test_as_json_involving_last_result_set
    expected = {
      'type' => 'articles',
      'id' => '1',
      'attributes' => {
        'title' => 'Rails is Omakase'
      }
    }
    stub_request(:post, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }]
      }.to_json)

    resource = Article.create
    assert_equal expected, resource.as_json
  end

  def test_as_json_api
    expected = {
      'type' => 'articles',
      'attributes' => {
        'foo' => 'bar',
        'qwer' => 'asdf'
      }
    }

    article = Article.new(foo: 'bar', qwer: 'asdf')
    assert_equal expected, article.as_json_api
  end

  def test_as_json_api_with_relationships
    expected = {
      'type' => 'articles',
      'attributes' => {
        'foo' => 'bar',
        'qwer' => 'asdf'
      },
      'relationships' => {
        'author' => {
          'data' => {
            'type' => 'people',
            'id' => 123
          }
        }
      }
    }

    article = Article.new(foo: 'bar', qwer: 'asdf')
    article.relationships.author = Person.new(id: 123, name: 'Bob')

    assert_equal expected, article.as_json_api
  end

  def test_update_data_only_includes_relationship_data
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          },
          relationships: {
            author: {
              links: {
                self: "http://example.com/posts/1/relationships/author",
                related: "http://example.com/posts/1/author"
              },
              data: {
                type: "people",
                id: "9"
              }
            }
          }
        }],
        included: [{
          type: "people",
          id: "9",
          attributes: {
            name: "Jeff"
          }
        }]
      }.to_json)

    articles = Article.all
    article = articles.first

    expected = {
      "type" => "articles",
      "id" => "1",
      "attributes" => {}
    }
    assert_equal expected, article.as_json_api
  end

  def test_update_data_only_includes_relationship_data_with_all_attributes_dirty
    stub_request(:get, "http://example.com/articles")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"},
                   body: {
                       data: [{
                                  type: "articles",
                                  id: "1",
                                  attributes: {
                                      title: "JSON API paints my bikeshed!"
                                  },
                                  relationships: {
                                      author: {
                                          links: {
                                              self: "http://example.com/posts/1/relationships/author",
                                              related: "http://example.com/posts/1/author"
                                          },
                                          data: {
                                              type: "people",
                                              id: "9"
                                          }
                                      }
                                  }
                              }],
                       included: [{
                                      type: "people",
                                      id: "9",
                                      attributes: {
                                          name: "Jeff"
                                      }
                                  }]
                   }.to_json)

    articles = Article.all
    article = articles.first
    article.set_all_dirty!

    expected = {
        "type" => "articles",
        "id" => "1",
        "attributes" => {
            "title" => "JSON API paints my bikeshed!"
        },
        "relationships" => {
            "author" => {
                "data" => {
                    "type" => "people",
                    "id" => "9"
                }
            }
        }
    }
    assert_equal expected, article.as_json_api
  end

  def test_skips_read_only_attributes
    resource = LimitedField.new({
      id: 1,
      foo: "bar",
      qwer: "asdf"
    })

    expected = {
      'id' => 1,
      'type' => 'limited_fields',
      'attributes' => {
        'qwer' => 'asdf'
      }
    }
    assert_equal(expected, resource.as_json_api)
  end

  def test_can_specify_attributes_for_serialization
    resource = CustomSerializerAttributes.new

    expected = {
      "type" => "custom_serializer_attributes",
      "attributes" => {
        "foo" => "bar"
      }
    }
    assert_equal expected, resource.as_json_api
  end

  def test_inherited_attributes_for_serialization
    resource = InheritedCustomSerializerAttributes.new({
      foo: "bar",
      id: 1234,
      qwer: "asdf"
    })

    expected = {
      "type" => "inherited_custom_serializer_attributes",
      "id" => 1234,
      "attributes" => {
        "qwer" => "asdf"
      }
    }

    assert_equal expected, resource.as_json_api
  end

  def test_dasherized_attribute_key_serialization
    with_altered_config(Article, :json_key_format => :dasherized_key) do
      article = Article.new
      article.foo_bar = 'baz'

      json = article.as_json_api
      attributes = json[:attributes]

      assert_equal("baz", attributes['foo-bar'])
    end
  end

  def test_camelized_attribute_key_serialization
    with_altered_config(Article, :json_key_format => :camelized_key) do
      article = Article.new
      article.foo_bar = 'baz'

      json = article.as_json_api
      attributes = json[:attributes]

      assert_equal("baz", attributes['fooBar'])
    end
  end

  def test_underscored_attribute_key_serialization
    with_altered_config(Article, :json_key_format => :underscored_key) do
      article = Article.new
      article.foo_bar = 'baz'

      json = article.as_json_api
      attributes = json[:attributes]

      assert_equal("baz", attributes['foo_bar'])
    end
  end

  def test_dasherized_relationship_key_serialization
    with_altered_config(Article, :json_key_format => :dasherized_key) do
      expected = {
        'primary-author' => {
          'data' => {
            'type' => 'people',
            'id' => 123
          }
        }
      }

      article = Article.new
      article.relationships.primary_author = Person.new(id: 123, name: 'Bob')

      assert_equal expected, article.as_json_api['relationships']
    end
  end

  def test_camelized_relationship_key_serialization
    with_altered_config(Article, :json_key_format => :camelized_key) do
      expected = {
        'primaryAuthor' => {
          'data' => {
            'type' => 'people',
            'id' => 123
          }
        }
      }

      article = Article.new
      article.relationships.primary_author = Person.new(id: 123, name: 'Bob')

      assert_equal expected, article.as_json_api['relationships']
    end
  end

  def test_underscored_relationship_key_serialization
    with_altered_config(Article, :json_key_format => :underscored_key) do
      expected = {
        'primary_author' => {
          'data' => {
            'type' => 'people',
            'id' => 123
          }
        }
      }

      article = Article.new
      article.relationships.primary_author = Person.new(id: 123, name: 'Bob')

      assert_equal expected, article.as_json_api['relationships']
    end
  end

  def test_ensure_nested_path_params_not_serialized
    resource = NestedResource.new(foo: 'bar', id: 1, bar_id: 99)

    expected = {
      'id' => 1,
      'type' => "nested_resources",
      'attributes' => {
        'foo' => 'bar'
      }
    }

    assert_equal expected, resource.as_json_api
  end

end
