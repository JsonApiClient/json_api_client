module JsonApiClient
  module Middleware
    class ParseJson < Faraday::Middleware

      def call(environment)
        @app.call(environment).on_complete do |env|
          if process_response_type?(response_type(env))
            env[:raw_body] = env[:body]
            env[:body] = parse(env[:body])
          end
        end
      end

      private

      def parse(body)
        ::JSON.parse(body) unless body.strip.empty?
      end

      def response_type(env)
        type = env[:response_headers]['Content-Type'].to_s
        type = type.split(';', 2).first if type.index(';')
        type
      end

      def process_response_type?(type)
        !!type.match(/\bjson$/)
      end
    end
  end
end