module JsonApiClient
  module Helpers
    module Serializable
      extend ActiveSupport::Concern

      included do
        class_attribute :read_only_attributes, instance_accessor: false
        self.read_only_attributes = ['id', 'type', 'links', 'meta', 'relationships']

        class_attribute :read_only_relations, instance_accessor: false
        self.read_only_relations = []
      end

      def serializable_hash
        attributes.slice('id', 'type').tap do |h|
          relations_for_serialization.tap do |r|
            h['relationships'] = r unless r.empty?
          end
          h['attributes'] = attributes_for_serialization
        end
      end

      def set_all_dirty!
        set_all_attributes_dirty
        relationships.set_all_attributes_dirty if relationships
      end

      protected

      def attributes_for_serialization
        attributes.except(*self.class.read_only_attributes).slice(*changed)
      end

      def relations_for_serialization
        relationships.serializable_hash.except(*self.class.read_only_relations)
      end

    end
  end
end
