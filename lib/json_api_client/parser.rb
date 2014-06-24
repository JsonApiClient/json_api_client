module JsonApiClient
  class Parser

    class << self
      def parse(klass, response)
        data = response.body
        ResultSet.build(klass, data) do |result_set|
          handle_pagination(result_set, data)
          handle_links(result_set, data)
          handle_errors(result_set, data)
        end
      end

      private

      def handle_pagination(result_set, data)
        meta = data.fetch("meta", {})
        result_set.per_page = meta.fetch("per_page") do
          result_set.length
        end
        result_set.total_entries = meta.fetch("total_entries") do
          result_set.length
        end
        result_set.current_page = meta.fetch("current_page", 1)

        # can fall back to calculating via total entries and per_page
        result_set.total_pages = meta.fetch("total_pages") do
          (1.0 * result_set.total_entries / result_set.per_page).ceil rescue 1
        end

        # can fall back to calculating via per_page and current_page
        result_set.offset = meta.fetch("offset") do
          result_set.per_page * (result_set.current_page - 1)
        end
      end

      def handle_links(result_set, data)
        link_definition = LinkDefinition.new(data.fetch("links", {}))
        linked_data = LinkedData.new(data.fetch("linked", {}))

        result_set.each do |resource|
          resource.link_definition = link_definition
          resource.linked_data = linked_data
        end
      end

      def handle_errors(result_set, data)
        result_set.errors = data.fetch("meta", {}).fetch("errors", [])
      end
    end

  end
end