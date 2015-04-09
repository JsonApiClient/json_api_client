module JsonApiClient
  module Parsers
    class LegacyParser

      class << self
        def parse(klass, response)
          data = response.body
          ResultSet.build(klass, data) do |result_set|
            handle_meta(result_set, data)
            handle_pagination(result_set, data)
            handle_links(result_set, data)
            handle_errors(result_set, data)
          end
        end

        private

        def handle_meta(result_set, data)
          result_set.meta = data.fetch("meta", {})
        end

        def handle_pagination(result_set, data)
          result_set.per_page = result_set.meta.fetch("per_page") do
            result_set.length
          end
          result_set.total_entries = result_set.meta.fetch("total_entries") do
            result_set.length
          end
          result_set.current_page = result_set.meta.fetch("current_page") do
            result_set.meta.fetch("page", 1)
          end

          # can fall back to calculating via total entries and per_page
          result_set.total_pages = result_set.meta.fetch("total_pages") do
            (1.0 * result_set.total_entries / result_set.per_page).ceil rescue 1
          end

          # can fall back to calculating via per_page and current_page
          result_set.offset = result_set.meta.fetch("offset") do
            result_set.per_page * (result_set.current_page - 1)
          end
        end

        def handle_links(result_set, data)
          return if result_set.empty?

          linked_data = LinkedData.new(
                          data.fetch("linked", {}),
                          LinkDefinition.new(data.fetch("links", {})),
                          result_set.record_class
                        )

          result_set.each do |resource|
            resource.linked_data = linked_data
          end
        end

        def handle_errors(result_set, data)
          result_set.errors = result_set.meta.fetch("errors", [])
        end
      end

    end
  end
end
