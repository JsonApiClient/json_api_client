module JsonApiClient
  class Connection

    attr_reader :faraday

    def initialize(site)
      @faraday = Faraday.new(site) do |builder|
        builder.request :url_encoded
        builder.use Middleware::JsonRequest
        builder.response :json, content_type: /\bjson$/
        builder.adapter Faraday.default_adapter
      end
    end

    # insert middleware before ParseJson - middleware executed in reverse order - 
    #   inserted middleware will run after json parsed
    def use(middleware, *args, &block)
      faraday.builder.insert_before(FaradayMiddleware::ParseJson, middleware, *args, &block)
    end

    def delete(middleware)
      faraday.builder.delete(middleware)
    end

    def execute(query)
      faraday.send(query.request_method, query.path, query.params, query.headers)
    end

  end
end