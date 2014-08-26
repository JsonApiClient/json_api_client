module JsonApiClient
  module Helpers
    module Schemable
      extend ActiveSupport::Concern

      Field = Struct.new(:name, :type, :default) do
        def cast(value)
          return nil if value.nil?
          return value if type.nil?

          case type.to_sym
          when :int
            value.to_i
          when :string
            value.to_s
          when :float
            value.to_f
          when :boolean
            !!value
          else
            value
          end
        end
      end

      included do
        initializer do |obj, params|
          obj.send(:set_default_values)
        end
      end

      class Schema
        def initialize
          @fields = {}
        end

        def add(field)
          @fields[field.name.to_sym] = field
        end

        def size
          @fields.size
        end

        def each_property(&block)
          @fields.values.each(&block)
        end

        def [](property_name)
          @fields[property_name.to_sym]
        end
      end

      module ClassMethods
        def schema
          @schema ||= Schema.new
        end

        def property(name, options = {})
          schema.add(Field.new(name, options[:type], options[:default]))
        end

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
        !!self.class.schema[attr_name] || super
      end

      def set_default_values
        self.class.schema.each_property do |property|
          attributes[property.name] = property.default unless attributes.has_key?(property.name)
        end
      end

      def property_for(name)
        self.class.schema[name]
      end

    end
  end
end