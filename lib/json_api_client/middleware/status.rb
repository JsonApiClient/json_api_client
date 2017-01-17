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
          error_class = env[:resource].not_found_class
          raise error_class, env[:url]
        when 500..599
          error_class = env[:resource].server_error_class
          raise error_class, env[:url]
        end
      end
    end
  end
end
