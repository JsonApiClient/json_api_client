module JsonApiClient
  module Helpers
    module Serializable

      def serializable_hash
        attributes.slice('id', 'type').tap do |h|
          relationships.serializable_hash.tap do |r|
            h['relationships'] = r unless r.empty?
          end
          h['attributes'] = attributes_for_serialization
        end
      end

      def read_only_attributes
        [:id, :type, :links, :meta, :relationships]
      end

      protected

      def attributes_for_serialization
        attributes.except(*self.read_only_attributes.map(&:to_s))
      end

    end
  end
end
