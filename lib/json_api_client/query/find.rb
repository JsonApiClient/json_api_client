module JsonApiClient
  module Query
    class Find < Base

      def initialize(klass, args)
        @klass = klass
        case args
        when Array
          # find by ids
          @path = klass.table_name
          @params = {id: args}
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