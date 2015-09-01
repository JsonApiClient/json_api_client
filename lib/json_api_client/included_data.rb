module JsonApiClient
  class IncludedData
    attr_reader :data

    def initialize(result_set, data)
      @record_class = result_set.record_class
      grouped_data = data.group_by{|datum| datum["type"]}
      @data = grouped_data.inject({}) do |h, (type, records)|
        klass = Utils.compute_type(record_class, type.singularize.classify)
        h[type] = records.map do |datum|
          params = klass.parser.parameters_from_resource(datum)
          resource = klass.load(params)
          resource.last_result_set = result_set
          resource
        end.index_by(&:id)
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

    attr_reader :record_class

    # should return a resource record of some type for this linked document
    def record_for(link_def)
      data[link_def["type"]][link_def["id"]]
    end
  end
end
