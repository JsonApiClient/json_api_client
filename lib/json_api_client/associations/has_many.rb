module JsonApiClient
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(attr_name, options = {})
          association = HasMany::Association.new(attr_name, self, options)
          self.associations = self.associations + [association]
          property(attr_name, type: :association, association: association, multiple: true)
        end
      end

      class Association < BaseAssociation
      end
    end
  end
end
