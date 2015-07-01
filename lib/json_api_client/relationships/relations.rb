module JsonApiClient
  module Relationships
    class Relations
      include Helpers::DynamicAttributes

      def initialize(relations)
        self.attributes = relations
      end

      def present?
        attributes.present?
      end

      protected

      def set_attribute(name, value)
        attributes[name] = case value
        when JsonApiClient::Resource
          {data: value.as_relation}
        when Array
          {data: value.map(&:as_relation)}
        else
          value
        end
      end

    end
  end
end