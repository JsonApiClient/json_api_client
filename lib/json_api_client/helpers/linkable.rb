module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      included do
        attr_accessor :links,
                      :link_definition, 
                      :linked_data

        initializer do |obj, params|
          if params && links = params.delete("links")
            obj.links = links
          end
        end
      end

      def method_missing(method, *args)
        return super unless has_link?(method)

        ids = links[method.to_s]
        data = linked_data.data_for(method, ids, self)
        if data.empty?
          raise "no data found"
        end

        data
      end

      def respond_to?(symbol, include_all = false)
        return true if has_link?(symbol)
        super
      end

      private

      def has_link?(symbol)
        links && 
          links.has_key?(symbol.to_s) &&
          link_definition && 
          link_definition.has_link?(symbol.to_s)
      end
    end
  end
end