module JsonApiClient
  module Associations
    module HasMany
      class Association < BaseAssociation
        def query_builder(url)
          association_class.query_builder.new(
            association_class,
            requestor: association_class.requestor_class.new(association_class, url)
          )
        end

        def data(url)
          query_builder(url)
        end
      end
    end
  end
end
