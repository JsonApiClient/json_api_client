module JsonApiClient
  module Query
    class Base

      def self.method
        :get
      end

      def path
        klass.table_name
      end

      def params
        @args
      end

      attr_reader :klass, :headers
      def initialize(klass, args)
        @klass = klass
        @args = args
        @headers = {
          accept: 'text/json'
        }
      end

      def execute(faraday)
        faraday.send(self.class.method, "#{path}.json", params, headers)
      end

    end
  end
end