module JsonApiClient
  module Associations
    autoload :BaseAssociation, 'json_api_client/associations/base_association'
    autoload :BelongsTo, 'json_api_client/associations/belongs_to'
    autoload :HasMany, 'json_api_client/associations/has_many'
    autoload :HasOne, 'json_api_client/associations/has_one'
  end
end