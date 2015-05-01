module JsonApiClient
  module Query
    class Update < Base
      self.request_method = :patch

      def build_params(args)
        args = args.dup
        @params = {
          id: args[klass.primary_key],
          data: args
        }
      end

    end
  end
end