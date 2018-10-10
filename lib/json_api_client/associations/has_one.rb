module JsonApiClient
  module Associations
    module HasOne
      class Association < BaseAssociation
        def from_result_set(result_set)
          result_set.first
        end
      end
    end
  end
end