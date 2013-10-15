module JsonApiClient
  module Helpers
    module Attributable
      extend ActiveSupport::Concern

      included do
        attr_reader :attributes
        attr_accessor :errors
        initializer do |obj, params|
          obj.attributes = params
        end
      end

      def attributes=(attrs = {})
        @attributes ||= {}.with_indifferent_access
        @attributes.merge!(attrs)
      end

      def update_attributes(attrs = {})
        self.attributes = attrs
        save
      end

      def method_missing(method, *args, &block)
        if match = method.to_s.match(/^(.*)=$/)
          set_attribute(match[1], args.first)
        elsif has_attribute?(method)
          attributes[method]
        else
          super
        end
      end

      def persisted?
        attributes.has_key?(primary_key)
      end

      def query_params
        attributes.except(primary_key)
      end

      def to_param
        attributes.fetch(primary_key, "").to_s
      end

      protected

      def read_attribute(name)
        attributes.fetch(name, nil)
      end

      def set_attribute(name, value)
        attributes[name] = value
      end

      def has_attribute?(attr_name)
        attributes.has_key?(attr_name)
      end

    end
  end
end