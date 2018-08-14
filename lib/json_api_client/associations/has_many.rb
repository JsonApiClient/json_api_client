module JsonApiClient
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(attr_name, options = {})
          self.associations = self.associations + [HasMany::Association.new(attr_name, self, options)]
        end
      end

      class Association < BaseAssociation
        def query_builder(url)
          association_class.query_builder.new(
            association_class,
            association_class.requestor_class.new(association_class, url)
          )
        end

        def data(url)
          query_builder(url)
        end
      end
    end
  end
end
