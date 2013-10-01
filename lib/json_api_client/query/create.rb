module JsonApiClient
  module Query
    class Create < Base
      self.request_method = :post

      def params
        {klass.resource_name => @args}
      end

    end
  end
end