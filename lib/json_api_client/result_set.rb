require 'forwardable'

module JsonApiClient
  class ResultSet < Array
    extend Forwardable

    attr_accessor :errors,
                  :record_class,
                  :meta,
                  :pages,
                  :uri,
                  :links,
                  :implementation,
                  :relationships

    # pagination methods are handled by the paginator
    def_delegators :pages, :total_pages, :total_entries, :total_count, :offset, :per_page, :current_page, :limit_value, :next_page, :previous_page, :out_of_bounds?

    def has_errors?
      errors.present?
    end

  end
end
