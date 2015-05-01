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

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*=)$/
          links[method] = args.first
        else
          super
        end
      end
    end
  end
end