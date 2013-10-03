module JsonApiClient
  module Associations
    module BelongsTo
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(attr_name)
          associations.push(BelongsTo::Association.new(attr_name))
        end
      end

      class Association
        attr_accessor :attr_name
        def initialize(attr_name)
          @attr_name = attr_name
        end
      end
    end
  end
end