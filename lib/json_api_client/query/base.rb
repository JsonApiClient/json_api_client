module JsonApiClient
  module Query
    class Base
      class_attribute :request_method
      attr_reader :klass, :headers

      def initialize(klass, args)
        @klass = klass
        @args = args
        @headers = klass.default_headers.dup
      end

      def path
        klass.table_name
      end

      def params
        @args
      end

    end
  end
end