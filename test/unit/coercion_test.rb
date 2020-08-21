require 'test_helper'

class CoercionTest < MiniTest::Test
  TIME_STRING = '2015-04-28 10:45:35 -0700'

  class CoercionTypes < TestResource
    property :bool_me, type: :boolean
    property :float_me, type: :float
    property :int_me, type: :int
    property :integer_me, type: :integer
    property :string_me, type: :string
    property :time_me, type: :time
    property :decimal_me, type: :decimal
  end

  def test_create_entity_with_coercion
    stub_request(:post, "http://example.com/coercion_types").
      to_return(headers: {content_type: "application/vnd.api+json"},
                body: {
                  data: {
                    attributes: {
                      bool_me: "false",
                      float_me: "1.0",
                      int_me: "1",
                      integer_me: "2",
                      string_me: 1.0,
                      time_me: "2015-04-28 10:45:35 -0700",
                      decimal_me: "1.5"
                    },
                    type: "coercion_types",
                    id: 123
                  }
                }.to_json)

    coerced = CoercionTypes.create({
      bool_me: "false",
      float_me: '1.0',
      int_me: '1',
      integer_me: '2',
      string_me: 1.0,
      time_me: TIME_STRING,
      decimal_me: BigDecimal('1.5')
      })
    validate_coercion_targets coerced
  end

  def test_new_entity_with_coercion
    coerced = CoercionTypes.new({
      bool_me: "false",
      float_me: '1.0',
      int_me: '1',
      integer_me: '2',
      string_me: 1.0,
      time_me: TIME_STRING,
      decimal_me: '1.5'
      })
    validate_coercion_targets coerced
  end

  def test_can_parse_and_coerce
    stub_request(:get, "http://example.com/coercion_types/1").
      to_return(headers: {content_type: "application/vnd.api+json"},
                body: {
                  data: {
                    attributes: {
                      bool_me: "false",
                      float_me: "1.0",
                      int_me: "1",
                      integer_me: "2",
                      string_me: 1.0,
                      time_me: "2015-04-28 10:45:35 -0700",
                      decimal_me: "1.5"
                    },
                    type: "coercion_types",
                    id: 1
                  }
                }.to_json)
    res = CoercionTypes.find(1)
    assert res.is_a?(JsonApiClient::ResultSet)
    validate_coercion_targets res.first
  end

  private
  def validate_coercion_targets(target)
    assert_equal target.bool_me, false
    assert_equal target.float_me, 1.0
    assert_equal target.int_me, 1
    assert_equal target.integer_me, 2
    assert_equal target.string_me, '1.0'
    assert_equal target.time_me, Time.parse(TIME_STRING)
    assert_equal target.decimal_me, BigDecimal('1.5')
  end
end
