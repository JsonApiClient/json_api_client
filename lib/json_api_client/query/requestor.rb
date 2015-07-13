module JsonApiClient
  module Query
    class Requestor
      extend Forwardable

      def initialize(klass)
        @klass = klass
      end

      # expects a record
      def create(record)
        request(:post, klass.path(record.attributes), {
          data: record.serializable_hash
        })
      end

      def update(record)
        request(:patch, resource_path(record.attributes), {
          data: record.serializable_hash
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

      attr_reader :klass
      def_delegators :klass, :connection

      def resource_path(parameters)
        if resource_id = parameters[klass.primary_key]
          File.join(klass.path(parameters), encoded(resource_id))
        else
          klass.path(parameters)
        end
      end

      def encoded(part)
        Addressable::URI.encode_component(part, Addressable::URI::CharacterClasses::UNRESERVED)
      end

      def request(type, path, params)
        klass.parse(connection.run(type, path, params, klass.custom_headers))
      end

    end
  end
end
