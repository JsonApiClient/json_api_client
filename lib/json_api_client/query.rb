module JsonApiClient
  module Query
    autoload :Base, 'json_api_client/query/base'
    autoload :Create, 'json_api_client/query/create'
    autoload :Custom, 'json_api_client/query/custom'
    autoload :Destroy, 'json_api_client/query/destroy'
    autoload :Find, 'json_api_client/query/find'
    autoload :Update, 'json_api_client/query/update'
  end
end