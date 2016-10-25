require 'test_helper'
require 'logger'

class NullConnection
  def initialize(*args)
  end

  def run(*args)
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

class CustomAdapterResource < TestResource
  TEST_STUBS = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.get('/custom_adapter_resources') { |env| [200, {content_type: "application/vnd.api+json"}, {data: [{id: "1", type: "custom_adapter_resources", attributes: {foo: "bar"}}]}.to_json] }
  end
  # The Faraday test adapter takes options when building the adapter
  self.connection_options = {
    adapter: [:test, TEST_STUBS]
  }
end

class ConnectionTest < MiniTest::Test

  def test_basic
    assert_equal(NullConnection, CustomConnectionResource.connection_class)

    NullConnection.any_instance.expects(:run)
    CustomConnectionResource.find(1)
  end

  def test_inherited
    assert_equal(NullConnection, InheritedConnectionResource.connection_class)

    NullConnection.any_instance.expects(:run)
    CustomConnectionResource.find(1)
  end

  def test_child_inherits_parents_connection
    assert InheritedConnectionResource.new.kind_of?(CustomConnectionResource), "sanity"
    assert_equal CustomConnectionResource.connection.object_id, InheritedConnectionResource.connection.object_id, "child connection should use it's parent's connection"
  end

  def test_can_specify_connection_adapter_options
    CustomAdapterResource.connection(true)
    resources = CustomAdapterResource.all
    assert_equal 1, resources.length
    resource = resources.first
    assert_equal "bar", resource.foo
  end

  def test_can_specify_http_proxy
    CustomAdapterResource.connection_options[:proxy] = 'http://proxy.example.com'
    CustomAdapterResource.connection(true)
    proxy = CustomAdapterResource.connection.faraday.proxy
    assert_equal proxy.uri.to_s, 'http://proxy.example.com'
  end

end
