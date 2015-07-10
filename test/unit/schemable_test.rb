require 'test_helper'

class SchemaResource < TestResource
  property :a, type: :string, default: 'foo'
  property :b, type: :boolean, default: false
  property :c
  property :d, type: :integer
end

class SchemaResource2 < TestResource
  property :a, type: :float
end

class MultipleSchema < TestResource
  properties :name, :short_name, :long_name, type: :string
end

class DateTypes < TestResource
  property :ts, type: :timestamp
  property :ts_in_ms, type: :timestamp_ms
  property :dt, type: :datetime
  property :d, type: :date
end

class SchemableTest < MiniTest::Unit::TestCase

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
    assert_equal nil, resource.c
    assert_equal nil, resource.d
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
      assert_equal nil, property.default
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

  def test_time_fields
    resource = DateTypes.new({
      ts: "1436543113",
      ts_in_ms: "1436543113000",
      dt: "2015-07-10 08:45:13 -0700",
      d: "2015-07-10"
    })

    assert resource.ts.is_a?(DateTime), "expected to cast a timestamp to a DateTime object"
    assert resource.ts_in_ms.is_a?(DateTime), "expected to cast a timestamp in ms to a DateTime object"
    assert resource.dt.is_a?(DateTime), "expected to cast a datetime string to a DateTime object"
    assert resource.d.is_a?(Date), "expected to cast a date string to a Date object"

    expected_date = DateTime.new(2015, 07, 10, 8, 45, 13, "-7")
    assert_equal expected_date, resource.ts
    assert_equal expected_date, resource.ts_in_ms
    assert_equal expected_date, resource.dt
    assert_equal expected_date.to_date, resource.d
  end

end