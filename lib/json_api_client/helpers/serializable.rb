module JsonApiClient
  module Helpers
    module Serializable
      RESERVED = ['id', 'type', 'links', 'meta', 'relationships']

      def serializable_hash
        attributes.slice('id', 'type').tap do |h|
          relationships.serializable_hash.tap do |r|
            h['relationships'] = r unless r.empty?
          end
          h['attributes'] = attributes.except(*RESERVED)
        end
      end
      alias data serializable_hash

    end
  end
end
