require 'test_helper'

class ParserTest < MiniTest::Unit::TestCase

  def test_basic
    assert JsonApiClient::Parser.is_a?(Class)
  end

  def test_meta_is_accessible_indifferently
    result = JsonApiClient::ResultSet.new
    args = [result, mock_response]
    JsonApiClient::Parser.send('handle_meta', *args)
    assert_equal(200, result.meta["status"])
    assert_equal(200, result.meta[:status])
    assert_equal(1, result.meta["page"])
    assert_equal(1, result.meta[:page])
    assert_equal(9999, result.meta["total_pages"])
    assert_equal(9999, result.meta[:total_pages])
  end

  private

  def mock_response
    {
        "meta": {
            "per-page": 10,
            "page": 1,
            "status": 200,
            "total_pages": 9999,
            "errors": nil
        }
    }.stringify_keys!
  end

end