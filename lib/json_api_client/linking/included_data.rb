module JsonApiClient
  module Linking
    class IncludedData
      attr_reader :data

      def initialize(record_class, data)
        grouped_data = data.group_by{|datum| datum["type"]}
        @data = grouped_data.inject({}) do |h, (type, records)|
          klass = Utils.compute_type(record_class, type.singularize.classify)
          h[type] = records.map{|datum| klass.new(datum)}.index_by(&:id)
          h
        end
      end

      def data_for(method_name, definition)
        linkage = definition["linkage"]
        if linkage.is_a?(Array)
          # has_many link
          linkage.map do |link_def|
            record_for(link_def)
          end
        else
          # has_one link
          record_for(linkage)
        end
      end

      def has_link?(name)
        data.has_key?(name)
      end

      private

      # should return a resource record of some type for this linked document
      def record_for(link_def)
        data[link_def["type"]][link_def["id"]]
      end
    end
  end
end