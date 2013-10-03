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
        def parse(param)
          [param].flatten.map{|data| association_class.new(data) }
        end
      end
    end
  end
end