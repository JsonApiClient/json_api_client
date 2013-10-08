module JsonApiClient
  module Query
    class Destroy < Base
      self.request_method = :delete

      def params
        nil
      end

    end
  end
end