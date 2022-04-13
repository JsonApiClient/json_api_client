module JsonApiClient
  module Associations
    module HasOne
      class Association < BaseAssociation
        def from_result_set(result_set)
          result_set.first
        end

        def load_records(data)
          record_class = Utils.compute_type(klass, klass.key_formatter.unformat(data["type"]).classify)
          record_class.load id: data["id"]
        end
      end
    end
  end
end
