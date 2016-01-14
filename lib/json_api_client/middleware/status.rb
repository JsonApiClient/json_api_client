module JsonApiClient
  module Middleware
    class Status < Faraday::Middleware
      CONNECTION_ERRORS = [
          # Faraday 0.8.*
          "Faraday::Error::ConnectionFailed",
          "Faraday::Error::TimeoutError",
          # Faraday 0.9.*
          "Faraday::ConnectionFailed",
          "Faraday::TimeoutError"].map do |e|
        Module.const_get(e) rescue nil
      end.compact

      def call(environment)
        @app.call(environment).on_complete do |env|
          handle_status(env[:status], env)

          # look for meta[:status]
          if env[:body].is_a?(Hash)
            code = env[:body].fetch("meta", {}).fetch("status", 200).to_i
            handle_status(code, env)
          end
        end
      rescue => ex
        if CONNECTION_ERRORS.include?(ex.class)
          raise Errors::ConnectionError, environment
        end
        raise
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
        when 400..499
          # some other error
        when 500..599
          raise Errors::ServerError, env
        else
          raise Errors::UnexpectedStatus.new(code, env[:url])
        end
      end
    end
  end
end