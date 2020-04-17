module JsonApiClient
  module Relationships
    class Relations
      include Helpers::DynamicAttributes
      include Helpers::Dirty
      include ActiveModel::Serialization

      attr_reader :record_class
      delegate :key_formatter, to: :record_class

      def initialize(record_class, relations)
        @record_class = record_class
        self.attributes = relations
      end

      def present?
        attributes.present?
      end

      def as_json_api
        Hash[attributes_for_serialization.map do |k, v|
               [k, v.slice("data")]  if v.has_key?("data")
             end.compact]
      end

      def as_json
        Hash[attributes.map do |k, v|
               [k, v.slice("data")]  if v.has_key?("data")
             end.compact]
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
        when NilClass
          {data: nil}
        else
          value
        end
        attribute_will_change!(name) if value != attributes[name]
        attributes[name] = value
      end

    end
  end
end
