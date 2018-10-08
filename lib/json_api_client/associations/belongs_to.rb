module JsonApiClient
  module Associations
    module BelongsTo
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
