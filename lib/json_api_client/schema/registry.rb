module JsonApiClient
  module Schema
    class Registry
      def initialize
        @properties = {}
      end

      Property = Struct.new(:name, :type_class, :default) do
        def cast(value)
          type_class.cast(value)
        end

        def type
          type_class.type
        end
      end

      # Add a property to the schema
      #
      # @param name [Symbol] the name of the property
      # @param options [Hash] property options
      # @option options [Symbol] :type The property type
      # @option options [Symbol] :default The default value for the property
      # @return [void]
      def add(name, options)
        @properties[name.to_sym] = Property.new(name, Types.build(options), options.delete(:default))
      end

      # How many properties are defined
      #
      # @return [Fixnum] the number of defined properties
      def size
        @properties.size
      end
      alias_method :length, :size

      def each_property(&block)
        @properties.values.each(&block)
      end
      alias_method :each, :each_property

      # Look up a property by name
      #
      # @param property_name [String] the name of the property
      # @return [Property, nil] the property definition for property_name or nil
      def find(property_name)
        @properties[property_name.to_sym]
      end
      alias_method :[], :find
    end
  end
end
