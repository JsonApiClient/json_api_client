module JsonApiClient
  module Helpers
    module DynamicAttributes

      def attributes
        @attributes
      end

      def attributes=(attrs = {})
        @attributes ||= ActiveSupport::HashWithIndifferentAccess.new

        return @attributes unless attrs.present?
        attrs.each do |key, value|
          set_attribute(key, value)
        end
      end

      def [](key)
        read_attribute(key)
      end

      def []=(key, value)
        set_attribute(key, value)
      end

      def respond_to_missing?(method, include_private = false)
        if (method.to_s =~ /^(.*)=$/) || has_attribute?(method)
          true
        else
          super
        end
      end

      def has_attribute?(name)
        attributes.has_key?(name) || attributes.has_key?(name.to_s.dasherize)
      end

      protected

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*)=$/
          set_attribute($1, args.first)
        elsif has_attribute?(method)
          read_attribute(method)
        else
          super
        end
      end

      def read_attribute(name)
        attributes.fetch(name) { attributes.fetch(name.to_s.dasherize, nil) }
      end

      def set_attribute(name, value)
        attributes[name] = value
      end

    end
  end
end
