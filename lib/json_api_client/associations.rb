module JsonApiClient
  module Associations
    autoload :BelongsTo, 'json_api_client/associations/belongs_to'
    autoload :HasMany, 'json_api_client/associations/has_many'
    autoload :HasOne, 'json_api_client/associations/has_one'

    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []

      include BelongsTo
      include HasMany
      include HasOne

      initialize :load_associations
    end

    protected

    def load_associations(params)
      associations.each do |association|
        params.fetch(association.param_name)
      end
    end

  end
end