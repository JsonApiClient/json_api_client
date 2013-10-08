module JsonApiClient
  class ResultSet < Array

    attr_accessor :total_pages, :total_entries, :offset, :per_page, :current_page, :errors

    def self.build(klass, data)
      result_data = data.fetch(klass.table_name, [])
      new(result_data.map {|attributes| klass.new(attributes) }).tap do |result_set|
        yield(result_set) if block_given?
      end
    end
  end
end