require 'test_helper'

class ParserTest < MiniTest::Unit::TestCase

  def test_basic
    assert JsonApiClient::Parser.is_a?(Class)
  end

end