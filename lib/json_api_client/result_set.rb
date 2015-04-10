require 'forwardable'

module JsonApiClient
  class ResultSet < Array
    extend Forwardable

    attr_accessor :errors,
                  :record_class,
                  :meta,
                  :pages

    def_delegators :pages, :total_pages, :total_entries, :offset, :per_page, :current_page, :limit_value, :next_page, :previous_page, :out_of_bounds?

    def self.build(klass, data)
      # Objects representing an individual resource are
      # not necessarily wrapped in an Array; enforce wrapping
      result_data = [data.fetch(klass.table_name, [])].flatten
      new(result_data.map {|attributes| klass.new(attributes) }).tap do |result_set|
        result_set.record_class = klass
        yield(result_set) if block_given?
      end
    end

    def has_errors?
      errors && errors.length > 0
    end

  end
end
