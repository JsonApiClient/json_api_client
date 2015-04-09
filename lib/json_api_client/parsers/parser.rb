module JsonApiClient
  module Parsers
    class Parser
      class << self
        def parse(klass, response)
          data = response.body
          ResultSet.new.tap do |result_set|
            result_set.record_class = klass
            handle_data(result_set, data)
            handle_errors(result_set, data)
            handle_meta(result_set, data)
            handle_links(result_set, data)
            handle_included(result_set, data)
          end
        end

        private

        def handle_data(result_set, data)
          # all data lives under the "data" attribute
          results = data.fetch("data", [])

          # we will treat everything as an Array
          results = [results] unless results.is_a?(Array)
          result_set.concat(results.map{|res| result_set.record_class.new(res)})
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