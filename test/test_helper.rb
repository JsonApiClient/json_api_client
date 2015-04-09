require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
Bundler.require(:default, :test)
require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/mini_test'
require 'pp'

WebMock.disable_net_connect!(:allow => "codeclimate.com")

class TestResource < JsonApiClient::Resource
  self.site = "http://localhost:3000/"
  self.parser = JsonApiClient::Parsers::Parser
end

class Article < TestResource
end