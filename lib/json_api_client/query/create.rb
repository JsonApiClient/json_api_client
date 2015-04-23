module JsonApiClient
  module Query
    class Create < Base
      self.request_method = :post

      def build_params(args)
        @params = {'data' => args.except(klass.primary_key)}
      end

      # we've nested the parameters, so un-nest them
      def build_path(parameters)
        super(parameters['data'])
      end

    end
  end
end
