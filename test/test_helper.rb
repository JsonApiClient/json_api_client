require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/mini_test'
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