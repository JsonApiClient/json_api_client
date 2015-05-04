module JsonApiClient
  module Query
    class Requestor
      extend Forwardable

      def initialize(klass)
        @klass = klass
      end

      # expects a record
      def create(record)
        request(:post, collection_path(record.attributes), {
          data: record.attributes
        })
      end

      def update(record)
        request(:patch, resource_path(record.attributes), {
          data: record.attributes
        })
      end

      def find(args)
        params = case args
        when Hash
          args
        when Array
          {klass.primary_key.to_s.pluralize.to_sym => args.join(",")}
        else
          {klass.primary_key => args}
        end

        path = klass.path(params)
        if params.has_key?(klass.primary_key) && !params[klass.primary_key].is_a?(Array)
          resource_id = params.delete(klass.primary_key).to_s
          encoded_resource_id = Addressable::URI.encode_component(resource_id, Addressable::URI::CharacterClasses::UNRESERVED)
          path = File.join(path, encoded_resource_id)
        end

        request(:get, path, params)
      end

      def destroy(record)
        request(:delete, path_for_resource(resource), {})
      end

      def linked(path)
        request(:get, path, {})
      end

      protected

      attr_reader :klass
      def_delegators :klass, :connection

      def collection_path(parameters)
        klass.path(parameters)
      end

      def resource_path(parameters)
        if resource_id = parameters[klass.primary_key]
          encoded_resource_id = Addressable::URI.encode_component(resource_id, Addressable::URI::CharacterClasses::UNRESERVED)
          File.join(klass.path(parameters), encoded_resource_id)
        else
          klass.path(parameters)
        end
      end

      def params_for_resource(resource)
        {data: resource.attributes}
      end

      def request(type, path, params)
        klass.parse(connection.run(type, path, params))
      end

    end
  end
end