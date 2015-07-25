module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      included do
        prepend Initializer
        class_attribute :linker, instance_accessor: false
        self.linker = Linking::Links

        # the links for this resource
        attr_accessor :links
      end

      module Initializer
        def initialize(params = {})
          links = params ? params.delete("links") : {}
          self.links = self.class.linker.new(links)
          super
        end
      end

    end
  end
end
