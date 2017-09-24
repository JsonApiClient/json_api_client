module JsonApiClient
  module Associations
    module BelongsTo
      extend ActiveSupport::Concern

      module ClassMethods
        def belongs_to(attr_name, options = {})
          # self.associations = self.associations + [HasOne::Association.new(attr_name, self, options)]
          self.associations += [BelongsTo::Association.new(attr_name, self, options)]
        end
      end

      class Association < BaseAssociation
        include Helpers::URI
        def param
          :"#{attr_name}_id"
        end

        def to_prefix_path(formatter)
          "#{formatter.format(attr_name.to_s.pluralize)}/%{#{param}}"
        end

        def set_prefix_path(attrs, formatter)
          attrs[param] = encode_part(attrs[param]) if attrs.key?(param)
          to_prefix_path(formatter) % attrs
        end
      end
    end
  end
end
