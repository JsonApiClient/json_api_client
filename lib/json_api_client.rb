require 'faraday_middleware'

module JsonApiClient
  autoload :Connection, 'json_api_client/connection'
  autoload :Query, 'json_api_client/query'
  autoload :Resource, 'json_api_client/resource'
end