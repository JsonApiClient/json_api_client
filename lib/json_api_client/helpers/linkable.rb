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
        attr_accessor :links,
                      :linked_data

        initializer do |obj, params|
          if params && links = params.delete("links")
            obj.links = Linker.new(links)
          end
        end
      end

      def method_missing(method, *args)
        return super unless links.has_link?(method)
        linked_data.data_for(method, links[method])
      end

      def respond_to?(symbol, include_all = false)
        return true if links && links.has_link?(symbol)
        super
      end

    end
  end
end