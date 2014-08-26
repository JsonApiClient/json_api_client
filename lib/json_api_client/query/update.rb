module JsonApiClient
  module Query
    class Update < Base
      self.request_method = :put

      def build_params(args)
        args = args.dup
        @params = {klass.primary_key => args.delete(klass.primary_key), klass.resource_name => args}
      end

    end
  end
end