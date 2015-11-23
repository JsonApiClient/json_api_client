require 'test_helper'

class InheritanceTest < Minitest::Test

  def test_inherited_resource_url
    assert_equal "http://foo.com/inherited_endpoints", InheritedEndpoint.resource
  end

end
