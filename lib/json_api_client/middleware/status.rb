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
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError
        raise Errors::ConnectionError, environment
      end

      def self.raise_on(*codes)
        statuses = codes.map { |code| code.is_a?(Range) ? code.to_a : code }
        @error_status_codes = statuses.flatten.compact
      end

      def self.error_status_codes
        @error_status_codes ||= []
      end

      protected

      def handle_status(code, env)
        case code
        when 200..399
        when 401
          raise Errors::NotAuthorized, env
        when 403
          raise Errors::AccessDenied, env
        when 404
          raise Errors::NotFound, env[:url]
        when 409
          raise Errors::Conflict, env
        when 400..499
          if self.class.error_status_codes.include?(code)
            raise Errors::ApiError, env
          end
        when 500..599
          raise Errors::ServerError, env
        else
          raise Errors::UnexpectedStatus.new(code, env[:url])
        end
      end
    end
  end
end
