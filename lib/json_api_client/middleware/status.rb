module JsonApiClient
  module Middleware
    class Status < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |env|
          handle_status(env[:status], env)

          # look for meta[:status]
          if env[:body].is_a?(Hash)
            code = env[:body].fetch("meta", {}).fetch("status", 200).to_i
            handle_status(code, env)
          end
        end
      end

      protected

      def handle_status(code, env)
        case code
        when 404
          raise Errors::NotFound, env[:uri]
        when 500..599
          raise Errors::ServerError, env
        end
      end
    end
  end
end