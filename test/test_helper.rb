Bundler.require(:default, :test)
require 'minitest/autorun'
require 'webmock/minitest'
require 'pp'

# test resources
class TestResource < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"
end

# basic resource
class User < TestResource
end

# for testing primary key option
class UserPreference < TestResource
  self.primary_key = :user_id
end

class InheritedEndpoint < TestResource
  self.site = "http://foo.com"
end