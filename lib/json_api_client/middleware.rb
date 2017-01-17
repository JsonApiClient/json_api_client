module JsonApiClient
  module Middleware
    autoload :JsonRequest, 'json_api_client/middleware/json_request'
    autoload :ParseJson, 'json_api_client/middleware/parse_json'
    autoload :Status, 'json_api_client/middleware/status'
    autoload :InsertResource, 'json_api_client/middleware/insert_resource'
  end
end
