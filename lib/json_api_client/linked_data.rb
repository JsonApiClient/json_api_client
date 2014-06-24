module JsonApiClient
  class LinkedData
    attr_accessor :type

    def initialize(data)
      @results_by_type_by_id = {}
      data.each do |type, results|
        @results_by_type_by_id[type] = results.inject({}){|collection, result| collection[result["id"]] = result; collection }
      end
    end

    def has_data?(type)
      data_for(type).present?
    end

    def data_for(type, ids, record_context)
      # the name of the linked data is provided by the link definition from the result
      attr_name = record_context.link_definition.attribute_name_for(type)

      # get any preloaded data from the result
      type_data = @results_by_type_by_id.fetch(attr_name, {})

      # find the associated class for the data
      klass = Utils.compute_type(record_context.class, type.to_s.classify)

      # return all the found records
      Array(ids).map do |id|
        result = type_data[id]
        result = klass.new(type_data[id]) if result
        result
      end
    end

  end
end