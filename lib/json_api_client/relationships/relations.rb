module JsonApiClient
  module Relationships
    class Relations
      include Helpers::DynamicAttributes

      def initialize(relations)
        self.attributes = relations
        clear_changes_information
      end

      def present?
        attributes.present?
      end

      def serializable_hash
        Hash[attributes_for_serialization.map do |k, v|
               [k, v.slice("data")]
             end]
      end

      def attributes_for_serialization
        attributes.slice(*changed)
      end

      protected

      def set_attribute(name, value)
        value = case value
        when JsonApiClient::Resource
          {data: value.as_relation}
        when Array
          {data: value.map(&:as_relation)}
        else
          value
        end
        attribute_will_change!(name) if value != attributes[name]
        attributes[name] = value
      end

    end
  end
end