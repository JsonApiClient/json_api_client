require 'faraday'
require 'faraday_middleware'
require 'json'

module JsonApiClient
  autoload :Associations, 'json_api_client/associations'
  autoload :Attributes, 'json_api_client/attributes'
  autoload :Connection, 'json_api_client/connection'
  autoload :Errors, 'json_api_client/errors'
  autoload :Links, 'json_api_client/links'
  autoload :Middleware, 'json_api_client/middleware'
  autoload :Parser, 'json_api_client/parser'
  autoload :Query, 'json_api_client/query'
  autoload :Resource, 'json_api_client/resource'
  autoload :ResultSet, 'json_api_client/result_set'
  autoload :Scope, 'json_api_client/scope'
  autoload :Utils, 'json_api_client/utils'
end