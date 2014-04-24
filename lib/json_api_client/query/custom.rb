module JsonApiClient
  module Query
    class Custom < Base

      def request_method
        @request_method
      end

      def path
        [@path, @options[:name]].join("/")
      end

      def build_params(params)
        opts = params.dup
        @request_method = opts.delete(:request_method) || :get
        @params = opts.delete(:params) || {}
        @options = opts
      end

    end
  end
end