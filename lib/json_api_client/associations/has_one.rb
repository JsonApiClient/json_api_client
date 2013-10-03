module JsonApiClient
  module Associations
    module HasOne
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one(attr_name, options = {})
          # self.associations = self.associations + [HasOne::Association.new(attr_name, self, options)]
          self.associations += [HasOne::Association.new(attr_name, self, options)]
        end
        alias belongs_to has_one
      end

      class Association < BaseAssociation
        def parse(params)
          params ? association_class.new(params) : nil
        end        
      end
    end
  end
end