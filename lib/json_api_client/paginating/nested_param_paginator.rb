module JsonApiClient
  module Paginating
    # An alternate, more consistent Paginator that always wraps
    # pagination query string params in a top-level wrapper_name,
    # e.g. page[offset]=2, page[limit]=10.
    class NestedParamPaginator
      DEFAULT_WRAPPER_NAME = "page".freeze
      DEFAULT_PAGE_PARAM = "page".freeze
      DEFAULT_PER_PAGE_PARAM = "per_page".freeze

      # Define class accessors as methods to enforce standard way
      # of defining pagination related query string params.
      class << self

        def wrapper_name
          @_wrapper_name ||= DEFAULT_WRAPPER_NAME
        end

        def wrapper_name=(param = DEFAULT_WRAPPER_NAME)
          raise ArgumentError, "don't wrap wrapper_name" unless valid_param?(param)

          @_wrapper_name = param.to_s
        end

        def page_param
          @_page_param ||= DEFAULT_PAGE_PARAM
          "#{wrapper_name}[#{@_page_param}]"
        end

        def page_param=(param = DEFAULT_PAGE_PARAM)
          raise ArgumentError, "don't wrap page_param" unless valid_param?(param)

          @_page_param = param.to_s
        end

        def per_page_param
          @_per_page_param ||= DEFAULT_PER_PAGE_PARAM
          "#{wrapper_name}[#{@_per_page_param}]"
        end

        def per_page_param=(param = DEFAULT_PER_PAGE_PARAM)
          raise ArgumentError, "don't wrap per_page_param" unless valid_param?(param)

          @_per_page_param = param
        end

        private

        def valid_param?(param)
          !(param.nil? || param.to_s.include?("[") || param.to_s.include?("]"))
        end

      end

      attr_reader :params, :result_set, :links

      def initialize(result_set, data)
        @params = params_for_uri(result_set.uri)
        @result_set = result_set
        @links = data["links"]
      end

      def next
        result_set.links.fetch_link("next")
      end

      def prev
        result_set.links.fetch_link("prev")
      end

      def first
        result_set.links.fetch_link("first")
      end

      def last
        result_set.links.fetch_link("last")
      end

      def total_pages
        if links["last"]
          uri = result_set.links.link_url_for("last")
          last_params = params_for_uri(uri)
          last_params.fetch(page_param, &method(:current_page)).to_i
        else
          current_page
        end
      end

      # this is an estimate, not necessarily an exact count
      def total_entries
        per_page * total_pages
      end
      def total_count; total_entries; end

      def offset
        per_page * (current_page - 1)
      end

      def per_page
        params.fetch(per_page_param) do
          result_set.length
        end.to_i
      end

      def current_page
        params.fetch(page_param, 1).to_i
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

      def page_param
        self.class.page_param
      end

      def per_page_param
        self.class.per_page_param
      end

      alias limit_value per_page

      protected

      def params_for_uri(uri)
        return {} unless uri
        uri = Addressable::URI.parse(uri)
        ( uri.query_values || {} ).with_indifferent_access
      end
    end
  end
end
