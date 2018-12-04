module JsonApiClient
  module Errors
    class ApiError < StandardError
      attr_reader :env
      def initialize(env, msg = nil)
        super msg
        @env = env
      end
    end

    class ClientError < ApiError
    end

    class AccessDenied < ClientError
    end

    class NotAuthorized < ClientError
    end

    class ConnectionError < ApiError
    end

    class ServerError < ApiError
      def initialize(env, msg = 'Internal server error')
        super env, msg
      end
    end

    class Conflict < ServerError
      def initialize(env, msg = 'Resource already exists')
        super env, msg
      end
    end

    class NotFound < ServerError
      attr_reader :uri
      def initialize(uri)
        @uri = uri
      end
      def message
        "Couldn't find resource at: #{uri.to_s}"
      end
    end

    class UnexpectedStatus < ServerError
      attr_reader :code, :uri
      def initialize(code, uri)
        @code = code
        @uri = uri
      end
      def message
        "Unexpected response status: #{code} from: #{uri.to_s}"
      end
    end
  end
end
