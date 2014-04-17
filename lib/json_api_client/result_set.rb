module JsonApiClient
  class ResultSet < Array

    attr_accessor :total_pages, :total_entries, :offset, :per_page, :current_page, :errors
    alias_attribute :limit_value, :per_page

    def self.build(klass, data)
      result_data = data.fetch(klass.table_name, [])
      new(result_data.map {|attributes| klass.new(attributes) }).tap do |result_set|
        yield(result_set) if block_given?
      end
    end

    def out_of_bounds?
      current_page > total_pages
    end

    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end
  end
end