module JsonApiClient
  module Helpers
    module Queryable
      extend ActiveSupport::Concern

      included do
        class << self
          extend Forwardable
          def_delegators :new_scope, :where, :order, :includes, :all, :paginate, :page, :first
        end
      end

      module ClassMethods
        def new_scope
          Scope.new(self)
        end

        def connection
          @connection ||= begin
            super
          rescue
            build_connection
          end
          yield(@connection) if block_given?
          @connection
        end

        def build_connection
          connection_class.new(site)
        end

        def connection_class
          Connection
        end
      end

    end
  end
end