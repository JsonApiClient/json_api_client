module JsonApiClient
  module Helpers
    module Serializable
      def as_json(options={})
        attributes
      end

      def read_attribute_for_serialization(name)
        read_attribute(name)
      end
    end
  end
end