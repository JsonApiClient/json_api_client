module JsonApiClient
  module Query
    class Base
      class_attribute :request_method
      attr_reader :klass, :headers

      def initialize(klass, args)
        @klass = klass
        @args = args
        @headers = {
          accept: 'application/json'
        }
      end

      def path
        klass.table_name
      end

      def params
        @args
      end

      def execute(faraday)
        faraday.send(request_method, "#{path}.json", params, headers)
      end

    end
  end
end