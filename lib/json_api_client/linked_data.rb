# This object holds the preloaded data from the json response - essentially
#   the preloaded foreign keys
module JsonApiClient
  class LinkedData
    attr_reader :link_definition,
                :record_class

    extend Forwardable
    def_delegators :link_definition, :has_link?

    def initialize(data, link_definition, record_class)
      @link_definition = link_definition
      @record_class = record_class
      @results_by_type_by_id = {}

      data.each do |type, results|
        @results_by_type_by_id[type] = results.inject({}){|collection, result| collection[result["id"]] = result; collection }
      end
    end

    def data_for(type, ids)
      # the name of the linked data is provided by the link definition from the result
      attr_name = link_definition.attribute_name_for(type)

      # get any preloaded data from the result
      type_data = @results_by_type_by_id.fetch(attr_name, {})

      # find the associated class for the data
      klass = Utils.compute_type(record_class, type.to_s.classify)

      # return all the found records
      Array(ids).map do |id|
        result = type_data[id]
        result = klass.new(type_data[id]) if result
        result
      end
    end

  end
end