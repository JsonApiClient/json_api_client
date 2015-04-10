module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      class Linker
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

      included do
        # the links for this resource
        attr_accessor :links

        # reference to all of the preloaded data
        attr_accessor :linked_data

        initializer do |obj, params|
          links = params && params.delete("links")
          links ||= {}
          obj.links = Linker.new(links)
        end
      end

      def method_missing(method, *args)
        return super unless links && links.has_link?(method)
        linked_data.data_for(method, links[method])
      end

      def respond_to?(symbol, include_all = false)
        return true if links && links.has_link?(symbol)
        super
      end

    end
  end
end