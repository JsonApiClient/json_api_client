module JsonApiClient
  module Query
    class Linked
      attr_accessor :path

      def initialize(path)
        @path = path
      end

      def request_method
        :get
      end

      def headers
        {}
      end

      def params
        {}
      end

    end
  end
end