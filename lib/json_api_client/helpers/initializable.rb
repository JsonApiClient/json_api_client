module JsonApiClient
  module Helpers
    module Initializable
      extend ActiveSupport::Concern

      included do
        class_attribute :initializers, instance_accessor: false
        self.initializers = []
      end

      module ClassMethods
        def initializer(method = nil, &block)
          self.initializers.push(method || block)
        end
      end

      def initialize(params = {})
        self.class.initializers.each do |initializer|
          if initializer.respond_to?(:call)
            initializer.call(self, params)
          else
            self.send(initializer, params)
          end
        end
      end
    end
  end
end
