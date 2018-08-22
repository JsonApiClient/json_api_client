module JsonApiClient
  class IncludedData
    attr_reader :data

    def initialize(result_set, data)
      record_class = result_set.record_class
      grouped_data = data.group_by{|datum| datum["type"]}
      @data = grouped_data.inject({}) do |h, (type, records)|
        klass = Utils.compute_type(record_class, record_class.key_formatter.unformat(type).singularize.classify)
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
      # this method only returns an array. It's up to the caller to decide if it's going to return
      # just the first element if it's a has_one relationship. 
      # If data is defined, pull the record from the included data
      defined_data = definition["data"]
      return nil unless defined_data
      [defined_data].flatten.map do |link_def|
        # should return a resource record of some type for this linked document
        # even if there's no matching record included.
        if data[link_def["type"]] 
          data[link_def["type"]][link_def["id"]]
        else
          # if there's no matching record in included then go and get it given the data
          link_def["type"].underscore.classify.constantize.find(link_def["id"]).first
        end
      end
    end

    def has_link?(name)
      data.has_key?(name.to_s)
    end

  end
end
