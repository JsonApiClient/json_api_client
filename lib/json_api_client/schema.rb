require 'date'

module JsonApiClient
  class Schema
    DEFAULT_PROPERTY_TYPES = {
      int: -> (value) { value.to_i },
      integer: -> (value) { value.to_i },
      string: -> (value) { value.to_s },
      float: -> (value) { value.to_f },
      boolean: -> (value) { value.is_a?(String) ? (value != "false") : !!value },
      timestamp: -> (value) { value.is_a?(DateTime) ? value : Time.at(value.to_f).to_datetime },
      timestamp_ms: -> (value) { value.is_a?(DateTime) ? value : Time.at(value.to_f/1000).to_datetime },
      datetime: -> (value) { value.is_a?(DateTime) ? value : DateTime.parse(value.to_s) },
      date: -> (value) { value.is_a?(Date) ? value : Date.parse(value.to_s) }
    }

    class << self
      def property_types
        @property_types ||= DEFAULT_PROPERTY_TYPES
      end

      def register_property_type(name, caster)
        property_types[name.to_sym] = caster
      end

      def find_property_type(name)
        property_types[name.to_sym]
      end
    end

    Property = Struct.new(:name, :type, :default) do
      def cast(value)
        return nil if value.nil?
        return value if type.nil?

        if caster = Schema.find_property_type(type)
          caster.call(value)
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