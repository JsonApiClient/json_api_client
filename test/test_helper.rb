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

class ArticleNested < TestResource
  belongs_to :author, shallow_path: true
  has_many :comments
  has_one :author
end

class Person < TestResource
end

class Comment < TestResource
end

class User < TestResource
end

class ApiBadRequestHandler
  def self.call(_env)
    # do not raise exception
  end
end

class CustomUnauthorizedError < StandardError
  attr_reader :env

  def initialize(env)
    @env = env
    super('not authorized')
  end
end

class UserWithCustomStatusHandler < TestResource
  self.connection_options = {
      status_handlers: {
          400 => ApiBadRequestHandler,
          401 => ->(env) { raise CustomUnauthorizedError, env }
      }
  }
end

class UserPreference < TestResource
  self.primary_key = :user_id
end

class DocumentUser < TestResource
  resolve_custom_type 'document--files', 'DocumentFile'
end

class DocumentStore < TestResource
  resolve_custom_type 'document--files', 'DocumentFile'
  has_many :files, class_name: 'DocumentFile'
end

class DocumentFile < TestResource
  def self.resource_name
    'document--files'
  end
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
