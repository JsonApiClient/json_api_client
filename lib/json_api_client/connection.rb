module JsonApiClient
  class Connection

    attr_reader :faraday

    def initialize(options = {})
      site = options.fetch(:site)
      connection_options = options.slice(:proxy, :ssl, :request, :headers, :params)
      adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
      status_middleware_options = {}
      status_middleware_options[:custom_handlers] = options[:status_handlers] if options[:status_handlers].present?
      @faraday = Faraday.new(site, connection_options) do |builder|
        builder.request :json
        builder.use Middleware::JsonRequest
        builder.use Middleware::Status, status_middleware_options
        builder.use Middleware::ParseJson
        builder.use ::FaradayMiddleware::Gzip
        builder.adapter(*adapter_options)
      end
      yield(self) if block_given?
    end

    # insert middleware before ParseJson - middleware executed in reverse order -
    #   inserted middleware will run after json parsed
    def use(middleware, *args, &block)
      return if faraday.builder.locked?
      faraday.builder.insert_before(Middleware::ParseJson, middleware, *args, &block)
    end

    def delete(middleware)
      faraday.builder.delete(middleware)
    end

    def run(request_method, path, params: nil, headers: {}, body: nil)
      faraday.run_request(request_method, path, body, headers) do |request|
        request.params.update(params) if params
      end
    end

  end
end
