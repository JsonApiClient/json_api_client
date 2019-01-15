module JsonApiClient
  module Helpers
    module Dirty

      def changed?
        changed_attributes.present?
      end

      def changed
        changed_attributes.keys
      end

      def changed_attributes
        @changed_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def clear_changes_information
        @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
      end

      def forget_change!(attr)
        @changed_attributes.delete(attr.to_s)
      end

      def set_all_attributes_dirty
        attributes.each do |k, v|
          set_attribute_was(k, v)
        end
      end

      def attribute_will_change!(attr)
        return if attribute_changed?(attr)
        set_attribute_was(attr, attributes[attr])
      end

      def set_attribute_was(attr, value)
        begin
          value = value.duplicable? ? value.clone : value
          changed_attributes[attr] = value
        rescue TypeError, NoMethodError
        end
      end

      def attribute_was(attr) # :nodoc:
        attribute_changed?(attr) ? changed_attributes[attr] : attributes[attr]
      end

      def attribute_changed?(attr)
        changed.include?(attr.to_s)
      end

      def attribute_change(attr)
        [changed_attributes[attr], attributes[attr]] if attribute_changed?(attr)
      end

      protected

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*)_changed\?$/
          has_attribute?($1) ? attribute_changed?($1) : nil
        elsif method.to_s =~ /^(.*)_was$/
          has_attribute?($1) ? attribute_was($1) : nil
        else
          super
        end
      end

      def set_attribute(name, value)
        attribute_will_change!(name) if value != attributes[name] || !attributes.has_key?(name)
        super
      end

    end
  end
end
