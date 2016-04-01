module JsonApiClient
  module Associations
    module HasOne
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one(attr_name, options = {})
          association = HasOne::Association.new(attr_name, self, options)
          self.associations += [association]
          property(attr_name, type: :association, association: association)
        end
      end

      class Association < BaseAssociation
        def from_result_set(result_set)
          result_set.first
        end
      end
    end
  end
end
