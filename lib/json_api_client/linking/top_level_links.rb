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

      def fetch_link(link_name)
        link_definition = links.fetch(link_name.to_s)
        query = Query::Linked.new(link_definition)
        record_class.run_request(query)
      end
    end
  end
end