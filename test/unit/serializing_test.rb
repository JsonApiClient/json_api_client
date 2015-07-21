require 'test_helper'

class SerializingTest < MiniTest::Test

  class LimitedField < TestResource
    def read_only_attributes
      super + [:foo]
    end
  end

  class CustomLimitedField < TestResource
    def read_only_attributes
      if self.persisted?
        super + [:qwer]
      else
        super + [:foo]
      end
    end
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
    assert_equal expected, article.serializable_hash
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
    assert_equal(expected, resource.serializable_hash)
  end

  def test_skips_custom_read_only_attributes
    resource = CustomLimitedField.new({
                                    id: 1,
                                    foo: "bar",
                                    qwer: "asdf"
                                })

    expected_new_record = {
        'id' => 1,
        'type' => 'custom_limited_fields',
        'attributes' => {
            'qwer' => 'asdf'
        }
    }
    expected_persisted = {
        'id' => 1,
        'type' => 'custom_limited_fields',
        'attributes' => {
            'foo' => 'bar'
        }
    }
    assert_equal(expected_new_record, resource.serializable_hash)
    resource.mark_as_persisted!
    assert_equal(expected_persisted, resource.serializable_hash)
  end

  def test_can_specify_attributes_for_serialization
    resource = CustomSerializerAttributes.new

    expected = {
      "type" => "custom_serializer_attributes",
      "attributes" => {
        "foo" => "bar"
      }
    }
    assert_equal expected, resource.serializable_hash
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
  end

end