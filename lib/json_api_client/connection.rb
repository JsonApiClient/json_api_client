require "yeti_support/enumerable/dasherize_keys"

module JsonApiClient
  class Connection

    attr_reader :faraday

    def initialize(options = {})
      site = options.fetch(:site)
      adapter_options = Array(options.fetch(:adapter, Faraday.default_adapter))
      @faraday = Faraday.new(site) do |builder|
        builder.request :json
        builder.use Middleware::JsonRequest
        builder.use Middleware::Status
        builder.use Middleware::ParseJson
        builder.adapter *adapter_options
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
      # Dasherize the request
      #
      # The JSON API 1.0 spec recommends (http://jsonapi.org/recommendations/) that
      # member names SHOULD contain only a-z, 0-9, and the hyphen as separator
      # between multiple words.
      path = path.dasherize
      params = dasherize_params(params)

      faraday.send(request_method, path, params, headers)
    end

    def dasherize_params(params)
      params.dasherize_keys.tap do |p|
        # Dasherize the sort fields
        p["sort"] = p["sort"].dasherize if p.has_key?("sort")

        # Dasherize the sparse fieldset fields
        if p.has_key?("fields")
          p["fields"] = p["fields"].map do |resource, fields|
            { resource => fields.dasherize }
          end.inject(&:merge)
        end
      end
    end
    private :dasherize_params

  end
end
