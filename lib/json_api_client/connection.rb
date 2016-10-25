module JsonApiClient
  class Connection

    attr_reader :faraday

    def initialize(options = {})
      site = options.fetch(:site)
      connection_options = options.slice(:proxy, :ssl, :request, :headers, :params)
      adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
      @faraday = Faraday.new(site, connection_options) do |builder|
        builder.request :json
        builder.use Middleware::JsonRequest
        builder.use Middleware::Status
        builder.use Middleware::ParseJson
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

    def run(request_method, path, params = {}, headers = {})
      faraday.send(request_method, path, params, headers)
    end

  end
end
