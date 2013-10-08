module JsonApiClient
  module Query
    class Create < Base
      self.request_method = :post

      def build_params(args)
        @params = {klass.resource_name => args.except(klass.primary_key)}
      end

    end
  end
end