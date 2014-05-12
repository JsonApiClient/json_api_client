require 'test_helper'
require 'logger'

class NullConnection
  def initialize(*args)
  end

  def execute(query)
  end
end

class NullParser
  def self.parse(*args)
    # do nothing
  end
end

class CustomConnectionResource < TestResource
  self.connection_class = NullConnection
  self.parser = NullParser
end

class InheritedConnectionResource < CustomConnectionResource
end

class ConnectionTest < MiniTest::Unit::TestCase

  def test_basic
    assert_equal(NullConnection, CustomConnectionResource.connection_class)

    NullConnection.any_instance.expects(:execute)
    CustomConnectionResource.find(1)
  end

  def test_inherited
    assert_equal(NullConnection, InheritedConnectionResource.connection_class)

    NullConnection.any_instance.expects(:execute)
    CustomConnectionResource.find(1)
  end

end