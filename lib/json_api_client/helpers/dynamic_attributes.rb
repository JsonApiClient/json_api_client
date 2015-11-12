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
          send("#{key}=", value)
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

      def has_attribute?(attr_name)
        attributes.has_key?(attr_name)
      end

      protected

      def method_missing(method, *args, &block)
        normalized_method = JsonApiClient.configuration.key_formatter.unformat(method.to_s)

        if normalized_method =~ /^(.*)=$/
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

    end
  end
end
