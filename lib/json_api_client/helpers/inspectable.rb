module JsonApiClient
  module Helpers
    module Inspectable

      def inspect
        "#<#{self.class.name}:@attributes=#{attributes.inspect}>"
      end

    end
  end
end