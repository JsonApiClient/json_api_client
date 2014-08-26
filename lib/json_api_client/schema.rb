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

    def add(name, options)
      @properties[name.to_sym] = Property.new(name.to_sym, options[:type], options[:default])
    end

    def size
      @properties.size
    end
    alias_method :length, :size

    def each_property(&block)
      @properties.values.each(&block)
    end
    alias_method :each, :each_property

    def [](property_name)
      @properties[property_name.to_sym]
    end
    alias_method :find, :[]
  end
end