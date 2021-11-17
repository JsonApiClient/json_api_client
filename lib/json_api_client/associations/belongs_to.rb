module JsonApiClient
  module Associations
    module BelongsTo
      class Association < BaseAssociation
        include Helpers::URI

        attr_reader :param

        def initialize(attr_name, klass, options = {})
          super
          @param = options.fetch(:param, :"#{attr_name}_id").to_sym
          @shallow_path = options.fetch(:shallow_path, false)
        end

        def shallow_path?
          @shallow_path
        end

        def to_prefix_path(formatter)
          "#{formatter.format(attr_name.to_s.pluralize)}/%{#{param}}"
        end

        def set_prefix_path(attrs, formatter)
          return if shallow_path? && !attrs[param]
          attrs[param] = encode_part(attrs[param]) if attrs.key?(param)
          to_prefix_path(formatter) % attrs
        end
      end
    end
  end
end
