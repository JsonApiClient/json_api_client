module JsonApiClient
  module Helpers
    module Schemable
      extend ActiveSupport::Concern

      Field = Struct.new(:name, :type, :default)

      included do
        class_attribute :schema
        self.schema = []
      end

      module ClassMethods
        def property(name, options = {})

        end

        def properties(*names)
          options = names.last.is_a?(Hash) ? names.pop : {}
          names.each do |name|
            property name, options
          end
        end
      end
    end
  end
end