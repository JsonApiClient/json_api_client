require 'simplecov'
SimpleCov.start
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/minitest'
require 'pp'

# shim for ActiveSupport 4.0.x requiring minitest 4.2
unless defined?(Minitest::Test)
  Minitest::Test = Minitest::Unit::TestCase
end

WebMock.disable_net_connect!(:allow => "codeclimate.com")

class TestResource < JsonApiClient::Resource
  self.site = "http://example.com/"
end

class Article < TestResource
  has_many :comments
  has_one :author
end

class Person < TestResource
end

class Comment < TestResource
end

class User < TestResource
end

class UserPreference < TestResource
  self.primary_key = :user_id
end

def with_altered_config(resource_class, changes)
  # remember and overwrite config
  old_config_values = {}
  changes.each_pair do |key, value|
    old_config_values[key] = resource_class.send(key)
    resource_class.send("#{key}=", value)
  end

  yield

  # restore config
  old_config_values.each_pair do |key, value|
    resource_class.send("#{key}=", old_config_values[key])
  end
end
