require 'rack'

module JsonApiClient
  module Errors
    class ApiError < StandardError
      attr_reader :env

      def initialize(env, msg = nil)
        @env = env
        # Try to fetch json_api errors from response
        msg = track_json_api_errors(msg)

        super msg
      end

      private

      # Try to fetch json_api errors from response
      def track_json_api_errors(msg)
        return msg unless env.try(:body).kind_of?(Hash) || env.body.key?('errors')

        errors_msg = env.body['errors'].map { |e| e['title'] }.compact.join('; ').presence
        return msg unless errors_msg

        msg.nil? ? errors_msg : "#{msg} (#{errors_msg})"
        # Just to be sure that it is back compatible
      rescue StandardError
        msg
      end
    end

    class ClientError < ApiError
    end

    class ResourceImmutableError < StandardError
      def initialize(msg = 'Resource immutable')
        super msg
      end
    end

    class AccessDenied < ClientError
    end

    class NotAuthorized < ClientError
    end

    class NotFound < ClientError
      attr_reader :uri
      def initialize(uri)
        @uri = uri

        msg = "Resource not found: #{uri.to_s}"
        super nil, msg
      end
    end

    class RequestTimeout < ClientError
    end

    class Conflict < ClientError
      def initialize(env, msg = 'Resource already exists')
        super env, msg
      end
    end

    class TooManyRequests < ClientError
    end

    class ConnectionError < ApiError
    end

    class ServerError < ApiError
      def initialize(env, msg = nil)
        msg ||= begin
          status = env.status
          message = ::Rack::Utils::HTTP_STATUS_CODES[status]
          "#{status} #{message}"
        end

        super env, msg
      end
    end

    class InternalServerError < ServerError
    end

    class BadGateway < ServerError
    end

    class ServiceUnavailable < ServerError
    end

    class GatewayTimeout < ServerError
    end

    class UnexpectedStatus < ServerError
      attr_reader :code, :uri
      def initialize(code, uri)
        @code = code
        @uri = uri

        msg = "Unexpected response status: #{code} from: #{uri.to_s}"
        super nil, msg
      end
    end

    class RecordNotSaved < ServerError
      attr_reader :record

      def initialize(message = nil, record = nil)
        @record = record
      end
      def message
        "Record not saved"
      end
    end
  end
end
