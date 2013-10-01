Bundler.require(:default, :test)
require 'minitest/autorun'
require 'vcr'
require 'mocha'
require 'pp'
require 'ostruct'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :faraday
  c.ignore_localhost = false
end

class ResourceTest < MiniTest::Unit::TestCase
  def assert_requested(url, method = :get, params = {}, return_value = nil)
    response = OpenStruct.new(
      body: return_value.to_json
    )
    Faraday::Connection.any_instance.expects(method).with(url, params, nil).returns(response)
  end
end