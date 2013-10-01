module JsonApiClient
  module Query
    class Destroy < Base
      self.request_method = :delete

      def params
        nil
      end

      def path
        File.join(klass.table_name, @args.to_param)
      end

    end
  end
end