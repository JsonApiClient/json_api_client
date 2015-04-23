module JsonApiClient
  module Middleware
    class JsonRequest < Faraday::Middleware
      def call(environment)
        environment[:request_headers]["Content-Type"] = 'application/vnd.api+json'
        environment[:request_headers]["Accept"] = 'application/vnd.api+json'
        @app.call(environment)
      end
    end
  end
end
