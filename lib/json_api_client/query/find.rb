module JsonApiClient
  module Query
    class Find < Base
      self.request_method = :get

      def initialize(klass, args)
        super

        case args
        when Array
          # find by ids
          @path = klass.table_name
          @params = {klass.primary_key => args}
        when Hash
          # find by params hash
          @path = klass.table_name
          @params = args
        else
          # find by id
          @path = File.join(klass.table_name, args.to_s)
          @params = nil
        end
      end

      def path
        @path
      end

      def params
        @params
      end

    end
  end
end