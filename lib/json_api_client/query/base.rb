module JsonApiClient
  module Query
    class Base
      class_attribute :request_method
      attr_reader :klass, :headers, :path, :params

      def initialize(klass, args)
        @klass = klass
        build_params(args)
        @headers = klass.default_headers.dup
        build_path(@params)
      end

      def build_path(parameters)
        @path = begin
          p = klass.path(parameters)
          if parameters.has_key?(klass.primary_key) && !parameters[klass.primary_key].is_a?(Array)
            p = File.join(p, parameters.delete(klass.primary_key).to_s)
          end
          p
        end
      end

      def build_params(args)
        @params = args.dup
      end

      def inspect
        "#{self.class.name}: method: #{request_method}; path: #{path}; params: #{params}, headers: #{headers}"
      end

    end
  end
end
