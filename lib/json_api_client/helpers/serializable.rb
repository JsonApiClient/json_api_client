module JsonApiClient
  module Helpers
    module Serializable
      extend ActiveSupport::Concern

      included do
        class_attribute :read_only_attributes, instance_accessor: false
        self.read_only_attributes = ['id', 'type', 'links', 'meta', 'relationships']
      end

      def serializable_hash
        attributes.slice('id', 'type').tap do |h|
          relationships.serializable_hash.tap do |r|
            h['relationships'] = r unless r.empty?
          end
          h['attributes'] = attributes_for_serialization
        end
      end

      protected

      def attributes_for_serialization
        attributes.except(*self.class.read_only_attributes)
      end

    end
  end
end
