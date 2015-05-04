module JsonApiClient
  module Helpers
    module Attributable
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes
        attr_accessor :errors
        initializer do |obj, params|
          obj.attributes = params.merge(type: obj.class.table_name)
        end
      end

      module ClassMethods
        def load(params)
          new(params).tap do |resource|
            resource.mark_as_persisted!
          end
        end
      end

      def update_attributes(attrs = {})
        self.attributes = attrs
        save
      end

      def mark_as_persisted!
        @persisted = true
      end

      def persisted?
        !!@persisted
      end

      def query_params
        attributes.except(primary_key)
      end

      def to_param
        attributes.fetch(primary_key, "").to_s
      end

      protected

      def ==(other)
        self.class == other.class && attributes == other.attributes
      end

    end
  end
end
