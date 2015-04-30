require 'test_helper'

class ResourceTest < MiniTest::Unit::TestCase

  def test_basic
    assert_equal :id, Article.primary_key
    assert_equal "articles", Article.table_name
    assert_equal "article", Article.resource_name
    assert_equal "http://example.com/articles", Article.resource
  end

end