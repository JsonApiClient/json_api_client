module JsonApiClient
  module Linking
    class Links
      attr_reader :links
      def initialize(links)
        @links = links || {}
      end

      def has_link?(name)
        links.has_key?(name.to_s)
      end

      def [](key)
        links[key.to_s]
      end
    end
  end
end