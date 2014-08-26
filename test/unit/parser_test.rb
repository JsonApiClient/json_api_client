require 'test_helper'

class ParserTest < Minitest::Test

  def test_basic
    assert JsonApiClient::Parser.is_a?(Class)
  end

end
