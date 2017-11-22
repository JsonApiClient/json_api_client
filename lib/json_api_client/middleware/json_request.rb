module JsonApiClient
  module Middleware
    class JsonRequest < Faraday::Middleware
      def call(environment)
        accept_header = update_accept_header(environment[:request_headers])

        environment[:request_headers]["Content-Type"] = 'application/vnd.api+json'
        environment[:request_headers]["Accept"] = accept_header
        @app.call(environment)
      end

      private

      def update_accept_header(headers)
        return 'application/vnd.api+json' if headers["Accept"].nil?
        accept_params = headers["Accept"].split(",")

        unless accept_params.include?('application/vnd.api+json')
          accept_params.unshift('application/vnd.api+json')
        end

        accept_params.join(",")
      end
    end
  end
end
