module JsonApiClient
  module Paginating
    class Paginator
      def initialize(result_set, links)
        @uri = links["self"]
      end

      def next
      end

      def prev
      end

      def first
      end

      def last
      end

      def total_pages
      end

      def total_entries
      end

      def offset
      end

      def per_page
      end

      def current_page
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
    end
  end
end