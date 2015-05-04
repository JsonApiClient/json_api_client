module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      included do
        # the links for this resource
        attr_accessor :links

        # reference to all of the preloaded data
        attr_accessor :linked_data

        initializer do |obj, params|
          links = params && params.delete("links")
          links ||= {}
          obj.links = Linking::Links.new(links)
        end
      end

      def attributes
        super.tap do |attrs|
          attrs.merge!(links.links)
        end
      end

      def method_missing(method, *args)
        return super unless links && links.has_attribute?(method)
        linked_data.data_for(method, links[method])
      end

      def respond_to_missing?(symbol, include_all = false)
        return true if links && links.has_attribute?(symbol)
        super
      end

    end
  end
end