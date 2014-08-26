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

        return @attributes unless attrs.present?
        attrs.each do |key, value|
          set_attribute(key, value)
        end
      end

      def update_attributes(attrs = {})
        self.attributes = attrs
        save
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

      def [](key)
        read_attribute(key)
      end

      def []=(key, value)
        set_attribute(key, value)
      end

      def respond_to?(method, include_private = false)
        if (method.to_s =~ /^(.*)=$/) || has_attribute?(method)
          true
        else
          super
        end
      end

      protected

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*)=$/
          set_attribute($1, args.first)
        elsif has_attribute?(method)
          attributes[method]
        else
          super
        end
      end

      def read_attribute(name)
        attributes.fetch(name, nil)
      end

      def set_attribute(name, value)
        attributes[name] = value
      end

      def has_attribute?(attr_name)
        attributes.has_key?(attr_name)
      end

      def ==(other)
        self.class == other.class && attributes == other.attributes
      end

    end
  end
end
