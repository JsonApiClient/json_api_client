module JsonApiClient
  module Middleware
    class InsertResource < Faraday::Middleware
      attr_reader :resource

      def initialize(app, resource)
        @app = app
        @resource = resource
      end

      def call(environment)
        environment[:resource] = resource
        @app.call(environment)
      end
    end
  end
end
