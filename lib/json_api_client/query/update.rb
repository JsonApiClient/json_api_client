module JsonApiClient
  module Query
    class Update < Base
      self.request_method = :put

      def params
        {klass.resource_name => @args.query_params}
      end

      def path
        File.join(klass.table_name, @args.to_param)
      end

    end
  end
end