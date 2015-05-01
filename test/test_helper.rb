require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/mini_test'
require 'pp'

WebMock.disable_net_connect!(:allow => "codeclimate.com")

class TestResource < JsonApiClient::Resource
  self.site = "http://example.com/"
end

TIME_STRING = '2015-04-28 10:45:35 -0700'

class Article < TestResource
end

class Person < TestResource
end

class Comment < TestResource
end

class AdditionalTypes < TestResource
  property :created_at, type: :time
end
