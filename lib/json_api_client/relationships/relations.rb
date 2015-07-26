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

      def serializable_hash
        Hash[attributes_for_serialization.map do |k, v|
               [k, v.slice("data")]  if v.has_key?("data")
             end.compact]
      end

      protected

      def attributes_for_serialization
        attributes
      end

      def set_attribute(name, value)
        attributes[name] = case value
        when JsonApiClient::Resource
          {data: value.as_relation}
        when Array
          {data: value.map(&:as_relation)}
        when NilClass
          {data: nil}
        else
          value
        end
      end

    end
  end
end