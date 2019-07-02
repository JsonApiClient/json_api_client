module JsonApiClient
  module Middleware
    class Status < Faraday::Middleware
      def initialize(app, options)
        super(app)
        @options = options
      end

      def call(environment)
        @app.call(environment).on_complete do |env|
          handle_status(env[:status], env)

          # look for meta[:status]
          if env[:body].is_a?(Hash)
            code = env[:body].fetch("meta", {}).fetch("status", 200).to_i
            handle_status(code, env)
          end
        end
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        raise Errors::ConnectionError.new environment, e.to_s
      end

      private

      def custom_handler_for(code)
        @options.fetch(:custom_handlers, {})[code]
      end

      def handle_status(code, env)
        custom_handler = custom_handler_for(code)
        return custom_handler.call(env) if custom_handler.present?

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
        when 422
          # Allow to proceed as resource errors will be populated
        when 400..499
          raise Errors::ClientError, env
        when 500
          raise Errors::InternalServerError, env
        when 501..599
          raise Errors::ServerError, env
        else
          raise Errors::UnexpectedStatus.new(code, env[:url])
        end
      end
    end
  end
end
