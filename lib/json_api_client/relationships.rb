module JsonApiClient
  module Relationships
    autoload :IncludedData, "json_api_client/relationships/included_data"
    autoload :Relations, "json_api_client/relationships/relations"
    autoload :TopLevelRelations, "json_api_client/relationships/top_level_relations"
  end
end