module JsonApiClient
  module Query
    class Update < Base

      def self.method
        :put
      end

      def params
        {klass.resource_name => @args}
      end

    end
  end
end