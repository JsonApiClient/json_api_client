require 'test_helper'

class CustomTypeCaster
  def self.cast(*)
     :mock
  end
end

JsonApiClient::Schema.register custom: CustomTypeCaster

class SchemaResource < TestResource
  property :a, type: :string, default: 'foo'
  property :b, type: :boolean, default: false
  property :c
  property :d, type: :integer
end

class SchemaResource2 < TestResource
  property :a, type: :float
end

class SchemaResource3 < TestResource
  property :a, type: :custom
end

class MultipleSchema < TestResource
  properties :name, :short_name, :long_name, type: :string
end

class SchemableTest < MiniTest::Test

  def test_default_attributes
    resource = SchemaResource.new

    assert resource.attributes.has_key?(:a), ':a should be in attributes'
    assert resource.attributes.has_key?(:b), ':b should be in attributes'
    refute resource.attributes.has_key?(:c), ':c should not be in attributes'
    refute resource.attributes.has_key?(:d), ':d should not be in attributes'
  end

  def test_defines_fields
    resource = SchemaResource.new

    %w(a b c d).each do |method_name|
      assert resource.respond_to?(method_name), "should respond_to?(:#{method_name})"
      assert resource.respond_to?("#{method_name}="), "should respond_to?(:#{method_name}=)"
    end

    assert_equal 4, SchemaResource.schema.size
  end

  def test_defines_defaults
    resource = SchemaResource.new

    assert_equal 'foo', resource.a
    assert_equal 'foo', resource['a']
    assert_equal false, resource.b
    assert_equal false, resource['b']
    assert_nil resource.c
    assert_nil resource.d
  end

  def test_find_property_definition
    property = SchemaResource.schema[:a]
    assert property

    assert_equal :a, property.name
    assert_equal :string, property.type
    assert_equal 'foo', property.default
  end

  def test_casts_data
    resource = SchemaResource.new

    resource.b = "false"
    assert_equal false, resource.b, "should cast boolean strings"

    resource.d = "1"
    assert_equal 1, resource.d
  end

  # sanity to make sure we're not doing anything crazy with inheritance
  def test_schemas_do_not_collide
    assert_equal 4, SchemaResource.schema.size
    assert_equal 1, SchemaResource2.schema.size
  end

  def test_can_define_multiple_properties
    assert_equal 3, MultipleSchema.schema.size

    MultipleSchema.schema.each_property do |property|
      assert_equal :string, property.type
      assert_nil property.default
    end
  end

  def test_casts_values_when_instantiating
    resource = SchemaResource.new({
      a: 123,
      b: 'false',
      c: :blah,
      d: "12345"
    })
    assert_equal "123", resource.a
    assert_equal false, resource.b
    assert_equal :blah, resource.c
    assert_equal 12345, resource.d
  end

  def test_casts_values_when_bulk_assigning_attributes
    resource = SchemaResource.new
    resource.attributes = {
      a: 123,
      b: 'false',
      c: :blah,
      d: "12345"
    }
    assert_equal "123", resource.a
    assert_equal false, resource.b
    assert_equal :blah, resource.c
    assert_equal 12345, resource.d
  end

  def test_boolean_casts_to_true
    ["1", 1, "true", true].each do |v|
      resource = SchemaResource.new
      resource.b = v
      assert_equal true, resource.b
    end
  end

  def test_boolean_casts_to_false
    ["0", 0, "false", false].each do |v|
      resource = SchemaResource.new
      resource.b = v
      assert_equal false, resource.b
    end
  end

  def test_boolean_defaults_to_default
    resource = SchemaResource.new
    resource.b = :bogus
    assert_equal false, resource.b
  end

  def test_custom_types
    resource = SchemaResource3.new(a: 'anything')
    assert_equal :mock, resource.a
    assert_equal :mock, resource['a']
  end

end
