module JsonApiClient
  module Helpers
    module Relatable
      extend ActiveSupport::Concern

      included do
        class_attribute :relationship_linker
        self.relationship_linker = Relationships::Relations

        # the relationships for this resource
        attr_accessor :relationships

        # reference to all of the preloaded data
        attr_accessor :included_data

        initializer do |obj, params|
          relationships = params && params.delete("relationships")
          relationships ||= {}
          obj.relationships = obj.relationship_linker.new(relationships)
        end
      end

      def as_relation
        {
          :type => self.class.table_name,
          primary_key => self[primary_key]
        }
      end

      def attributes
        super.tap do |attrs|
          attrs.merge!(relationships: relationships.attributes) if relationships.present?
        end
      end

      def method_missing(method, *args)
        return super unless relationships && relationships.has_attribute?(method)
        included_data.data_for(method, relationships[method])
      end

      def respond_to_missing?(symbol, include_all = false)
        return true if relationships && relationships.has_attribute?(symbol)
        super
      end

    end
  end
end
