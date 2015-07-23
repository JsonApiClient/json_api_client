module JsonApiClient
  module Helpers
    module Attributable
      extend ActiveSupport::Concern

      included do
        include DynamicAttributes
        attr_accessor :errors
        initializer do |obj, params|
          obj.attributes = params.merge(obj.class.default_attributes)
        end
      end

      module ClassMethods
        def load(params)
          new(params).tap do |resource|
            resource.mark_as_persisted!
            resource.clear_dirty_attributes
          end
        end

        def default_attributes
          {type: table_name}
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
        !!@persisted && has_attribute?(primary_key)
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
