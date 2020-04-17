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
        if has_attribute?(method) || method.to_s.end_with?('=')
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
        if has_attribute?(method)
          return attributes[method]
        end

        normalized_method = safe_key_formatter.unformat(method.to_s)

        if normalized_method.end_with?('=')
          set_attribute(normalized_method[0..-2], args.first)
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

      def safe_key_formatter
        @safe_key_formatter ||= (key_formatter || DefaultKeyFormatter.new)
      end

      def key_formatter
        self.class.respond_to?(:key_formatter) && self.class.key_formatter
      end

      class DefaultKeyFormatter
        def unformat(method)
          method.to_s
        end
      end

    end
  end
end
