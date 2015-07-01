module JsonApiClient
  module Linking
    class Links
      include Helpers::DynamicAttributes

      def initialize(links)
        self.attributes = links
      end

      def present?
        attributes.present?
      end

      protected

      def set_attribute(name, value)
        attributes[name] = value
      end

    end
  end
end