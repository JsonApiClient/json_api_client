require 'active_model/attribute_methods'
require 'active_model/dirty'

module JsonApiClient
  module Helpers
    module DirtyAttributes
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Dirty
      end

      module ClassMethods
        def load(params)
          super.tap do |resource|
            resource.clear_changes!
          end
        end
      end

      def clear_changes!
        # call private `clear_changes_information`
        clear_changes_information
      end

      def set_all_attributes_dirty
        attributes.each do |k, v|
          set_attribute_was(k, v)
        end
      end

      def set_all_dirty!
        set_all_attributes_dirty
        relationships.set_all_attributes_dirty if relationships
      end

      protected

      def attributes_for_serialization
        super.slice(*changed)
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*)=$/
          set_attribute($1, args.first)
        elsif has_attribute?(method)
          attributes[method]
        elsif method.to_s =~ /^(.*)_changed\?$/
          has_attribute?($1) ? attribute_changed?($1) : nil
        elsif method.to_s =~ /^(.*)_was$/
          has_attribute?($1) ? attribute_was($1) : nil
        else
          super
        end
      end

      def set_attribute(name, value)
        attribute_will_change!(name) if value != attributes[name]
        super
      end

    end
  end
end