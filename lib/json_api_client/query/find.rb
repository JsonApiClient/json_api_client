module JsonApiClient
  module Query
    class Find < Base
      self.request_method = :get

      def build_params(args)
        @params = case args
        when Hash
          args
        else
          {klass.primary_key => args}
        end
      end

    end
  end
end