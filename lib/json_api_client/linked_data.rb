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
        klass = klass_for(type)
        add_data(type, results.map{|result| klass.new(result)})
      end

      @results_by_type_by_id.values.each do |results|
        results.values.each do |result|
          result.linked_data = self
        end
      end
    end

    def data_for(type, ids)
      ids = Array(ids)

      # the name of the linked data is provided by the link definition from the result
      attr_name = link_definition.attribute_name_for(type)

      # get any preloaded data from the result
      type_data = @results_by_type_by_id.fetch(attr_name, {})

      # find the associated class for the data
      klass = klass_for(type)

      # return all the found records
      found, missing = ids.partition { |id| type_data[id].present? }

      # make another api request if there are missing records
      fetch_data(klass, type, missing) if missing.present?

      # reload data
      type_data = @results_by_type_by_id.fetch(attr_name, {})

      ids.map do |id|
        type_data[id]
      end
    end

    # make an api request to fetch the missing data
    def fetch_data(klass, type, missing_ids)
      uri = URI(link_definition.url_for(type, missing_ids)).to_s

      query = Query::Linked.new(uri)
      results = klass.run_request(query)

      key = link_definition.attribute_name_for(type).to_s
      add_data(key, results)
    end

    def add_data(key, data)
      @results_by_type_by_id[key] ||= {}
      @results_by_type_by_id[key].merge!(data.index_by{|datum| datum["id"]})
    end

    def klass_for(type)
      Utils.compute_type(record_class, type.to_s.pluralize.classify)
    end

  end
end
