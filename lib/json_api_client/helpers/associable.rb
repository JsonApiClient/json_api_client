module JsonApiClient
  module Helpers
    module Associable
      extend ActiveSupport::Concern

      included do
        class_attribute :associations, instance_accessor: false
        self.associations = []

        include Associations::BelongsTo
        include Associations::HasMany
        include Associations::HasOne

        initializer :load_associations
      end

      module ClassMethods
        def belongs_to_associations
          associations.select{|association| association.is_a?(Associations::BelongsTo::Association) }
        end

        def prefix_params
          belongs_to_associations.map(&:param)
        end

        def prefix_path
          belongs_to_associations.map(&:to_prefix_path).join("/")
        end

        def path(params = nil)
          parts = [table_name]
          if params
            path_params = params.delete(:path) || params
            parts.unshift(prefix_path % path_params.symbolize_keys)
          else
            parts.unshift(prefix_path)
          end
          parts.reject!{|part| part == "" }
          File.join(*parts)
        rescue KeyError
          raise ArgumentError, "Not all prefix parameters specified"
        end
      end

      protected

      def load_associations(params)
        self.class.associations.each do |association|
          if params.has_key?(association.attr_name.to_s)
            set_attribute(association.attr_name, association.parse(params[association.attr_name.to_s]))
          end
        end
      end

    end
  end
end
