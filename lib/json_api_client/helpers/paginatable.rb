module JsonApiClient
  module Helpers
    module Paginatable
      extend ActiveSupport::Concern

      included do
        class_attribute :paginator, instance_accessor: false
        self.paginator = Paginating::Paginator
      end

    end
  end
end

