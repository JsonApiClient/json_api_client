module JsonApiClient
  module Query
    class Update < Base
      self.request_method = :put

      def build_params(args)
        @params = {klass.primary_key => args.dup.delete(klass.primary_key), klass.resource_name => args}
      end

    end
  end
end