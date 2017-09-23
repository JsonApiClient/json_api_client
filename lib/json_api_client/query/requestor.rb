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
          data: record.as_json_api
        })
      end

      def update(record)
        request(:patch, resource_path(record.attributes), {
          data: record.as_json_api
        })
      end

      def get(params = {})
        path = resource_path(params)
        params.delete(klass.primary_key)
        request(:get, path, params)
      end

      def destroy(record)
        request(:delete, resource_path(record.attributes), {})
      end

      def linked(path)
        request(:get, path, {})
      end

      def custom(method_name, options, params)
        path = resource_path(params)
        params.delete(klass.primary_key)
        path = File.join(path, method_name.to_s)

        request(options.fetch(:request_method, :get), path, params)
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

      def request(type, path, params)
        klass.parser.parse(klass, connection.run(type, path, params, klass.custom_headers))
      end

    end
  end
end
