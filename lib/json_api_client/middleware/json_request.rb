module JsonApiClient
  module Middleware
    class JsonRequest < Faraday::Middleware
      def call(environment)
        environment[:request_headers]["Accept"] = "application/vnd.api+json"
        @app.call(environment)
      end
    end
  end
end
