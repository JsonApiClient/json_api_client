module JsonApiClient
  module Paginating
    class LegacyPaginator
      attr_reader :meta, :result_set
      def initialize(result_set, meta)
        @meta = meta
        @result_set = result_set
      end

      def next
        raise NotImplementedError
      end

      def prev
        raise NotImplementedError
      end

      def first
        raise NotImplementedError
      end

      def last
        raise NotImplementedError
      end

      def total_pages
        meta.fetch("total_pages") do
          (1.0 * total_entries / per_page).ceil rescue 1
        end
      end

      def total_entries
        meta.fetch("total_entries") do
          result_set.length
        end
      end

      def offset
        meta.fetch("offset") do
          per_page * (current_page - 1)
        end
      end

      def per_page
        meta.fetch("per_page") do
          result_set.length
        end
      end

      def current_page
        meta.fetch("current_page") do
          meta.fetch("page", 1)
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

      alias limit_value per_page
    end
  end
end