module JsonApiClient
  module Query
    class Create < Base

      def self.method
        :post
      end

      def params
        {klass.resource_name => @args}
      end

    end
  end
end