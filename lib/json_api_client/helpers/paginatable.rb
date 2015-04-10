module JsonApiClient
  module Helpers
    module Paginatable
      extend ActiveSupport::Concern

      included do
        class_attribute :paginator
        self.paginator = Paginating::LegacyPaginator
      end

    end
  end
end