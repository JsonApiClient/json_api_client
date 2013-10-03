module JsonApiClient
  module Associations
    autoload :BaseAssociation, 'json_api_client/associations/base_association'
    autoload :HasMany, 'json_api_client/associations/has_many'
    autoload :HasOne, 'json_api_client/associations/has_one'

    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []

      include HasMany
      include HasOne

      initialize :load_associations
    end

    protected

    def load_associations(params)
      associations.each do |association|
        if params.has_key?(association.attr_name.to_s)
          set_attribute(association.attr_name, association.parse(params[association.attr_name.to_s]))
        end
      end
    end

  end
end