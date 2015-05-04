module JsonApiClient
  module Linking
    class Links
      include Helpers::DynamicAttributes

      def initialize(links)
        self.attributes = links
      end

    end
  end
end