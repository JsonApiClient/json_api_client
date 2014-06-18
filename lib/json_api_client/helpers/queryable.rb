module JsonApiClient
  module Helpers
    module Queryable
      extend ActiveSupport::Concern

      included do
        class << self
          extend Forwardable
          def_delegators :new_scope, :where, :order, :includes, :all, :paginate, :page, :first
        end
        class_attribute :connection_class, :connection_object, :connection_options
        self.connection_class = Connection
        self.connection_options = {}
      end

      module ClassMethods
        def new_scope
          Scope.new(self)
        end

        def connection
          unless connection_object
            self.connection_object = connection_class.new(connection_options.merge(site: site))
          end
          yield(connection_object) if block_given?
          connection_object
        end
      end

    end
  end
end