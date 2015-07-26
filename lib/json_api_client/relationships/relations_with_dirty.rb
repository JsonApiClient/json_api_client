module JsonApiClient
  module Relationships
    class RelationsWithDirty < Relations
      include Helpers::DirtyAttributes

      def initialize(relations)
        super
        clear_changes_information
      end

      protected

      def attributes_for_serialization
        super.slice(*changed)
      end

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