module JsonApiClient
  class IncludedData
    attr_reader :data

    def initialize(result_set, data)
      record_class = result_set.record_class
      included_set = data.map do |datum|
        type = datum["type"]
        klass = Utils.compute_type(record_class, record_class.key_formatter.unformat(type).singularize.classify)
        params = klass.parser.parameters_from_resource(datum)
        resource = klass.load(params)
        resource.last_result_set = result_set
        resource
      end

      included_set.concat(result_set) if record_class.search_included_in_result_set
      @data = included_set.group_by(&:type).inject({}) do |h, (type, resources)|
        h[type] = resources.index_by(&:id)
        h
      end
    end

    def data_for(method_name, definition)
      # If data is defined, pull the record from the included data
      return nil unless data = definition["data"]

      if data.is_a?(Array)
        # has_many link
        data.map do |link_def|
          record_for(link_def)
        end
      else
        # has_one link
        record_for(data)
      end
    end

    def has_link?(name)
      data.has_key?(name.to_s)
    end

    private

    # should return a resource record of some type for this linked document
    def record_for(link_def)
      type_data = data[link_def["type"]]
      type_data && type_data[link_def["id"]]
    end
  end
end
