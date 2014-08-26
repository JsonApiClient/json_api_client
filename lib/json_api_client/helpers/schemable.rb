module JsonApiClient
  module Helpers
    module Schemable
      extend ActiveSupport::Concern

      included do
        initializer do |obj, params|
          obj.send(:set_default_values)
        end
      end

      module ClassMethods
        # Returns the schema for this resource class
        #
        # @return [Schema] the schema for this resource class
        def schema
          @schema ||= Schema.new
        end

        # Declares a new property by name
        #
        # @param name [Symbol] the name of the property
        # @param options [Hash] property options
        # @option options [Symbol] :type The property type
        # @option options [Symbol] :default The default value for the property
        def property(name, options = {})
          schema.add(name, options)
        end

        # Declare multiple properties with the same optional options
        #
        # @param [Array<Symbol>] names
        # @param options [Hash] property options
        # @option options [Symbol] :type The property type
        # @option options [Symbol] :default The default value for the property
        def properties(*names)
          options = names.last.is_a?(Hash) ? names.pop : {}
          names.each do |name|
            property name, options
          end
        end
      end

      protected

      def set_attribute(name, value)
        property = property_for(name)
        value = property.cast(value) if property
        super(name, value)
      end

      def has_attribute?(attr_name)
        !!property_for(attr_name) || super
      end

      def set_default_values
        self.class.schema.each_property do |property|
          attributes[property.name] = property.default unless attributes.has_key?(property.name)
        end
      end

      def property_for(name)
        self.class.schema.find(name)
      end

    end
  end
end