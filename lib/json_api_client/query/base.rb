module JsonApiClient
  module Query
    class Base
      class_attribute :request_method
      attr_reader :klass, :headers, :path, :params

      def initialize(klass, args)
        @klass = klass
        build_params(args)
        @headers = klass.default_headers.dup

        @path = begin
          p = klass.path(@params)
          if @params.has_key?(klass.primary_key) && !@params[klass.primary_key].is_a?(Array)
            p = File.join(p, @params.delete(klass.primary_key).to_s)
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
