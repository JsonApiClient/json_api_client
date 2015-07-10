module JsonApiClient
  module Helpers
    module Queryable
      extend ActiveSupport::Concern

      included do
        class << self
          extend Forwardable
          def_delegators :new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :first, :find
        end
        class_attribute :connection_class, :connection_object, :connection_options, :query_builder, instance_accessor: false
        self.connection_class = Connection
        self.connection_options = {}
        self.query_builder = Query::Builder
      end

      module ClassMethods
        def new_scope
          query_builder.new(self)
        end

        def connection(&block)
          build_connection(&block)
          connection_object
        end

        def build_connection
          return connection_object unless connection_object.nil?
          self.connection_object = connection_class.new(connection_options.merge(site: site)).tap do |conn|
            yield(conn) if block_given?
          end
        end
      end

    end
  end
end