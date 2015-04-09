module JsonApiClient
  module Parsers
    class Parser
      class << self
        def parse(klass, response)
          data = response.body
          ResultSet.new.tap do |result_set|
            handle_data(result_set, data)
            handle_errors(result_set, data)
            handle_meta(result_set, data)
            handle_links(result_set, data)
            handle_included(result_set, data)
          end
        end

        private

        def handle_data(result_set, data)
          # all data 
          results = data.fetch("data", [])
        end

        def handle_errors(result_set, data)
          errors = data.fetch("errors", [])
        end

        def handle_meta(result_set, data)

        end

        def handle_links(result_set, data)

        end

        def handle_included(result_set, data)

        end
      end
    end
  end
end