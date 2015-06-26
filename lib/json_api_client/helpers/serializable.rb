module JsonApiClient
  module Helpers
    module Serializable
      RESERVED = ['id', 'type', 'links', 'meta', 'relationships']

      # def as_json(options=nil)
      #   attributes.slice(*RESERVED).tap do |h|
      #     h['attributes'] = serialized_attributes
      #   end
      # end

      def data
        attributes.slice(*RESERVED).tap do |h|
          h['attributes'] = serialized_attributes
        end
      end

      def serialized_attributes
        attributes.except(*RESERVED)
      end

    end
  end
end
