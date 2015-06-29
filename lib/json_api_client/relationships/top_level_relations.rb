module JsonApiClient
  module Relationships
    class TopLevelRelations

      attr_reader :relations, :record_class

      def initialize(record_class, relations)
        @relations = relations
        @record_class = record_class
      end

      def respond_to_missing?(method, include_private = false)
        relations.has_key?(method.to_s) || super
      end

      def method_missing(method, *args)
        if respond_to_missing?(method)
          fetch_relation(method)
        else
          super
        end
      end

      def fetch_relation(relation_name)
        link_definition = relations.fetch(relation_name.to_s)
        record_class.requestor.linked(link_definition)
      end
    end
  end
end
