require 'bigdecimal'
module JsonApiClient
  class Schema
    module Types

      class Integer
        def self.cast(value, _)
          value.to_i
        end
      end

      class String
        def self.cast(value, _)
          value.to_s
        end
      end

      class Float
        def self.cast(value, _)
          value.to_f
        end
      end

      class Time
        def self.cast(value, _)
          value.is_a?(::Time) ? value : ::Time.parse(value)
        end
      end

      class Decimal
        def self.cast(value, _)
          BigDecimal(value)
        end
      end

      class Boolean
        def self.cast(value, default)
          case value
            when "false", "0", 0, false
              false
            when "true", "1", 1, true
              true
            else
              # if it's unknown, use the default value
              default
          end
        end
      end

    end

    class TypeFactory
      @@types = {}
      # Register a new type key or keys with appropriate classes
      #
      # eg:
      #
      #   require 'money'
      #
      #   class MyMoneyCaster
      #      def self.cast(value, default)
      #         begin
      #           Money.new(value, "USD")
      #         rescue ArgumentError
      #           default
      #         end
      #      end
      #   end
      #
      #   JsonApiClient::Schema::TypeFactory.register money: MyMoneyCaster
      #
      # You can setup several at once:
      #
      #   JsonApiClient::Schema::TypeFactory.register money: MyMoneyCaster,
      #                                         date: MyJsonDateTypeCaster
      #
      #
      #
      #
      def self.register(type_hash)
        @@types.merge!(type_hash)
      end

      def self.type_for(type)
        @@types[type]
      end

      self.register int: Types::Integer,
                    integer: Types::Integer,
                    string: Types::String,
                    float: Types::Float,
                    time: Types::Time,
                    decimal: Types::Decimal,
                    boolean: Types::Boolean

    end

    Property = Struct.new(:name, :type, :default) do
      def cast(value)
        return nil if value.nil?
        return value if type.nil?
        type_caster = TypeFactory.type_for(type)
        return value if type_caster.nil?
        type_caster.cast(value, default)
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

    class << self
      def register(type_hash)
        TypeFactory.register(type_hash)
      end
    end
  end
end
