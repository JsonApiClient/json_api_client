module JsonApiClient
  module Query
    autoload :Base, 'json_api_client/query/base'
    autoload :Builder, 'json_api_client/query/builder'
    autoload :Create, 'json_api_client/query/create'
    autoload :Custom, 'json_api_client/query/custom'
    autoload :Destroy, 'json_api_client/query/destroy'
    autoload :Find, 'json_api_client/query/find'
    autoload :Update, 'json_api_client/query/update'
    autoload :Linked, 'json_api_client/query/linked'
    autoload :LegacyBuilder, 'json_api_client/query/legacy_builder'
  end
end