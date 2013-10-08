module JsonApiClient
  module Associations
    autoload :BaseAssociation, 'json_api_client/associations/base_association'
    autoload :BelongsTo, 'json_api_client/associations/belongs_to'
    autoload :HasMany, 'json_api_client/associations/has_many'
    autoload :HasOne, 'json_api_client/associations/has_one'

    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []

      include BelongsTo
      include HasMany
      include HasOne

      initialize :load_associations
    end

    module ClassMethods
      def belongs_to_associations
        associations.select{|association| association.is_a?(BelongsTo::Association) }
      end

      def prefix_params
        belongs_to_associations.map(&:param)
      end

      def prefix_path
        File.join("", belongs_to_associations.map(&:to_prefix_path))
      end

      def path(params = nil)
        if params
          slurp = params.slice(*prefix_params)
          prefix_params.each do |param|
            params.delete(param)
          end
          File.join(prefix_path % slurp, table_name)
        else
          File.join(prefix_path, table_name)
        end
      rescue KeyError
        raise ArgumentError, "Not all prefix parameters specified"
      end
    end

    protected

    def load_associations(params)
      associations.each do |association|
        if params.has_key?(association.attr_name.to_s)
          set_attribute(association.attr_name, association.parse(params[association.attr_name.to_s]))
        end
      end
    end

  end
end