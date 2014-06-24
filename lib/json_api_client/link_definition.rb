module JsonApiClient
  class LinkDefinition

    def initialize(spec)
      @spec = {}.with_indifferent_access
      spec.each do |type, definition|
        @spec[type.split(".").last] = definition.merge({slurp: type})
      end
    end

    def has_link?(type)
      @spec.has_key?(type)
    end

    def attribute_name_for(type)
      @spec.fetch(type).fetch("type")
    end

    def url_for(type, ids)
      @spec.fetch(type).fetch("href").gsub("{#{slurp}}", Array(ids).join(","))
    end

  end
end