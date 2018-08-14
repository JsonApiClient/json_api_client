module JsonApiClient
  module Query
    class Requestor
      extend Forwardable
      include Helpers::URI

      def initialize(klass, path = nil)
        @klass = klass
        @path = path
      end

      # expects a record
      def create(record)
        request(:post, klass.path(record.attributes), {
            body: { data: record.as_json_api },
            params: record.request_params.to_params
        })
      end

      def update(record)
        request(:patch, resource_path(record.attributes), {
            body: { data: record.as_json_api },
            params: record.request_params.to_params
        })
      end

      def get(params = {})
        path = resource_path(params)
        params.delete(klass.primary_key)
        request(:get, path, params: params)
      end

      def destroy(record)
        request(:delete, resource_path(record.attributes))
      end

      def linked(path)
        request(:get, path)
      end

      def custom(method_name, options, params)
        path = resource_path(params)
        params.delete(klass.primary_key)
        path = File.join(path, method_name.to_s)
        request_method = options.fetch(:request_method, :get).to_sym
        query_params, body_params = [:get, :delete].include?(request_method) ? [params, nil] : [nil, params]
        request(request_method, path, params: query_params, body: body_params)
      end

      protected

      attr_reader :klass, :path
      def_delegators :klass, :connection

      def resource_path(parameters)
        base_path = path || klass.path(parameters)
        if resource_id = parameters[klass.primary_key]
          File.join(base_path, encode_part(resource_id))
        else
          base_path
        end
      end

      def request(type, path, params: nil, body: nil)
        response = connection.run(type, path, params: params, body: body, headers: klass.custom_headers)
        klass.parser.parse(klass, response)
      end

    end
  end
end
