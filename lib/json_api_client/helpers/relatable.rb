module JsonApiClient
  module Helpers
    module Relatable
      extend ActiveSupport::Concern

      included do
        prepend Initializer
        class_attribute :relationship_linker, instance_accessor: false
        self.relationship_linker = Relationships::Relations

        # the relationships for this resource
        attr_accessor :relationships
      end

      module Initializer
        def initialize(params = {})
          relationship_params = params ? params.delete("relationships") : {}
          self.relationships = self.class.relationship_linker.new(relationship_params)
          super
        end
      end

      def as_relation
        {
          :type => self.class.table_name,
          primary_key => self[primary_key]
        }
      end

      def method_missing(method, *args)
        return super unless relationships and relationships.has_attribute?(method) and result_set.included
        result_set.included.data_for(method, relationships[method])
      end

      def respond_to_missing?(symbol, include_all = false)
        return true if relationships && relationships.has_attribute?(symbol)
        super
      end

    end
  end
end
