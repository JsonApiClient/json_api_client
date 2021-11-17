module JsonApiClient
  class IncludedData
    attr_reader :data

    def initialize(result_set, data)
      record_class = result_set.record_class
      grouped_data = data.group_by{|datum| datum["type"]}
      grouped_included_set = grouped_data.each_with_object({}) do |(type, records), h|
        klass = Utils.compute_type(record_class, record_class.key_formatter.unformat(type).singularize.classify)
        h[type] = records.map do |record|
          params = klass.parser.parameters_from_resource(record)
          klass.load(params).tap do |resource|
            resource.last_result_set = result_set
          end
        end
      end

      if record_class.search_included_in_result_set
        # deep_merge overrides the nested Arrays o_O
        # {a: [1,2]}.deep_merge(a: [3,4]) # => {a: [3,4]}
        grouped_included_set.merge!(result_set.group_by(&:type)) do |_, resources1, resources2|
          resources1 + resources2
        end
      end

      grouped_included_set.each do |type, resources|
        grouped_included_set[type] = resources.index_by(&:id)
      end

      @data = grouped_included_set
    end

    def data_for(method_name, definition)
      # If data is defined, pull the record from the included data
      return nil unless data = definition["data"]

      if data.is_a?(Array)
        # has_many link
        data.map(&method(:record_for)).compact
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
      record = data[link_def["type"]]
      record[link_def["id"]] if record
    end
  end
end
