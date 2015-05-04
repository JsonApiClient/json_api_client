module JsonApiClient
  class Connection

    attr_reader :faraday

    def initialize(options = {})
      site = options.fetch(:site)
      @faraday = Faraday.new(site) do |builder|
        builder.request :json
        builder.use Middleware::JsonRequest
        builder.use Middleware::Status
        builder.use Middleware::ParseJson
        builder.adapter Faraday.default_adapter
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

    def execute(query)
      run(query.request_method, query.path, query.params, query.headers)
    end

    def run(request_method, path, params = {}, headers = {})
      faraday.send(request_method, path, params, headers)
    end

  end
end
