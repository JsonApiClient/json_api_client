module JsonApiClient
  module Helpers
    module URI
      def encode_part(part)
        Addressable::URI.encode_component(part, Addressable::URI::CharacterClasses::UNRESERVED)
      end
    end
  end
end
