module JsonApiClient
  module Query
    class Destroy < Base

      def self.method
        :delete
      end

    end
  end
end