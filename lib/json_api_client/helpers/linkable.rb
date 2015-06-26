module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      included do
        class_attribute :linker
        self.linker = Linking::Links

        # the links for this resource
        attr_accessor :links

        attr_accessor :relationships

        # reference to all of the preloaded data
        attr_accessor :included_data

        initializer do |obj, params|
          links = params && params.delete("links")
          links ||= {}
          obj.links = obj.linker.new(links)

          relationships = params && params.delete("relationships")
          relationships ||= {}
          obj.relationships = obj.linker.new(relationships)
        end
      end

      def as_link
        {
          :type => self.class.table_name,
          primary_key => self[primary_key]
        }
      end

      def attributes
        super.tap do |attrs|
          attrs.merge!(relationships: relationships.attributes) if relationships.present?
        end
      end

      def method_missing(method, *args)
        return super unless relationships && relationships.has_attribute?(method)
        included_data.data_for(method, relationships[method])
      end

      def respond_to_missing?(symbol, include_all = false)
        return true if relationships && relationships.has_attribute?(symbol)
        super
      end

    end
  end
end
