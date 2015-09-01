module JsonApiClient
  module Associations
    module HasOne
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one(attr_name, options = {})
          self.associations += [HasOne::Association.new(attr_name, self, options)]
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