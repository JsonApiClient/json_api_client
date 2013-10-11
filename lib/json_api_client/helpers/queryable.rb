module JsonApiClient
  module Helpers
    module Queryable
      extend ActiveSupport::Concern

      included do
        self.class.send(:include, ClassExtensions)
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
          Connection.new(site)
        end
      end

      module ClassExtensions
        extend ActiveSupport::Concern

        included do
          extend Forwardable
          def_delegators :new_scope, :where, :order, :includes, :all, :paginate, :page, :first
        end
      end
    end
  end
end