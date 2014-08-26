module JsonApiClient
  class Schema
    Property = Struct.new(:name, :type, :default) do
      def cast(value)
        return nil if value.nil?
        return value if type.nil?

        case type.to_sym
        when :int, :integer
          value.to_i
        when :string
          value.to_s
        when :float
          value.to_f
        when :boolean
          if value.is_a?(String)
            value == "false" ? false : true
          else
            !!value
          end
        else
          value
        end
      end
    end

    def initialize
      @properties = {}
    end

    # Add a property to the schema
    #
    # @param name [Symbol] the name of the property
    # @param options [Hash] property options
    # @option options [Symbol] :type The property type
    # @option options [Symbol] :default The default value for the property
    # @return [void]
    def add(name, options)
      @properties[name.to_sym] = Property.new(name.to_sym, options[:type], options[:default])
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