module JsonApiClient
  class RequestParams
    attr_reader :klass, :includes, :fields

    def initialize(klass, includes: [], fields: {})
      @klass = klass
      @includes = includes
      @fields = fields
    end

    def add_includes(includes)
      Utils.parse_includes(klass, *includes).each do |name|
        name = name.to_sym
        self.includes.push(name) unless self.includes.include?(name)
      end
    end

    def reset_includes!
      @includes = []
    end

    def set_fields(type, field_names)
      self.fields[type.to_sym] = field_names.map(&:to_sym)
    end

    def remove_fields(type)
      self.fields.delete(type.to_sym)
    end

    def field_types
      self.fields.keys
    end

    def clear
      reset_includes!
      @fields = {}
    end

    def to_params
      return nil if field_types.empty? && includes.empty?
      parsed_fields.merge(parsed_includes)
    end

    private

    def parsed_includes
      return {} if includes.empty?
      {include: includes.join(",")}
    end

    def parsed_fields
      return {} if field_types.empty?
      {fields: fields.map { |type, names| [type, names.join(",")] }.to_h}
    end

  end
end
