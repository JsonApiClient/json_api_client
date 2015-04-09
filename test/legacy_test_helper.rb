require 'test_helper'

# test resources
class LegacyTestResource < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"
end

# basic resource
class User < LegacyTestResource
end

class Post < LegacyTestResource
end

class Address < LegacyTestResource
end

# for testing primary key option
class UserPreference < LegacyTestResource
  self.primary_key = :user_id
end

class InheritedEndpoint < LegacyTestResource
  self.site = "http://foo.com"
end

class CustomPagination < LegacyTestResource
end

# remaps meta data
class CustomPaginationMiddleware < Faraday::Middleware
  def call(environment)
    @app.call(environment).on_complete do |env|
      new_meta = {}
      env[:body]["meta"].tap do |meta|
        new_meta["per_page"] = meta["per"]
        new_meta["current_page"] = meta["page"]
        new_meta["total_entries"] = meta["total"]
      end
      env[:body]["meta"] = new_meta
    end
  end
end

CustomPagination.connection do |conn|
  conn.use CustomPaginationMiddleware
end
