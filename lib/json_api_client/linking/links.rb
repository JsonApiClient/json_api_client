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
        attributes[name] = case value
        when JsonApiClient::Resource
          {linkage: value.as_link}
        when Array
          {linkage: value.map(&:as_link)}
        else
          value
        end
      end

    end
  end
end