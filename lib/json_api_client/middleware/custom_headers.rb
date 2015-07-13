module JsonApiClient
  module Middleware
    class CustomHeaders < Faraday::Middleware
      attr_reader :klass, :app

      def initialize(app, klass)
        super(app)
        @klass = klass
      end

      def call(environment)
        environment[:request_headers] ||= {}
        environment[:request_headers].merge!(klass.custom_headers)
        @app.call(environment)
      end
    end
  end
end