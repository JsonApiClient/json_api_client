module JsonApiClient
  module Linking
    class TopLevelLinks

      attr_reader :links, :record_class

      def initialize(record_class, links)
        @links = links
        @record_class = record_class
      end

      def respond_to_missing?(method, include_private = false)
        links.has_key?(method.to_s) || super
      end

      def method_missing(method, *args)
        if respond_to_missing?(method)
          fetch_link(method)
        else
          super
        end
      end

      def link_url_for(link_name)
        link_definition = links.fetch(link_name.to_s)
        if link_definition.is_a?(Hash)
          link_definition["href"]
        else
          link_definition
        end
      end

      def fetch_link(link_name)
        record_class.requestor.linked(link_url_for(link_name))
      end
    end
  end
end
