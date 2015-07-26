module JsonApiClient
  module Relationships
    autoload :Relations, "json_api_client/relationships/relations"
    autoload :RelationsWithDirty, "json_api_client/relationships/relations_with_dirty"
    autoload :TopLevelRelations, "json_api_client/relationships/top_level_relations"
  end
end