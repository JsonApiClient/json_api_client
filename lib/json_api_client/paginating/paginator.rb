module JsonApiClient
  module Paginating
    class Paginator
      class_attribute :page_param,
                      :per_page_param

      self.page_param = "page"
      self.per_page_param = "per_page"

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
          last_params.fetch(page_param) do
            current_page
          end.to_i
        else
          current_page
        end
      end

      # this number may be off
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
