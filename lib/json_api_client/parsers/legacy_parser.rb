module JsonApiClient
  module Parsers
    class LegacyParser

      class << self
        def parse(klass, response)
          data = response.body
          ResultSet.build(klass, data) do |result_set|
            result_set.record_class = klass
            result_set.uri = response.env[:url]
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
          result_set.pages = result_set.record_class.paginator.new(result_set, result_set.meta)
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
