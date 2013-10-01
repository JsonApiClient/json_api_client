module JsonApiClient
  module Query
    class Update < Base
      self.request_method = :put

      def params
        {klass.resource_name => @args}
      end

    end
  end
end