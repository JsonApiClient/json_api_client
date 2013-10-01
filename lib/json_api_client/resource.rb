require 'forwardable'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

module JsonApiClient
  class Resource

    class << self
      # first 'scope' should build a new scope object
      extend Forwardable
      def_delegators :new_scope, :where, :order, :includes, :all

      def site
        raise "not implemented"
      end

      # base URL for this resource
      def resource
        File.join(site, table_name)
      end

      def new_scope
        Scope.new(self)
      end

      def table_name
        name.demodulize.underscore.pluralize
      end

      def primary_key
        :id
      end

      # see jsonapi.org - id style and url style
      def link_style
        :id # or :url
      end

      def find(conditions)
        connection.execute(Query::Find.new(self, conditions))
      end

      def create(conditions = {})
        connection.execute(Query::Create.new(self, conditions))
      end

      def connection
        @connection ||= begin
          super
        rescue
          build_connection
        end
      end

      private

      def build_connection
        Connection.new(site)
      end
    end

    attr_reader :links, :attributes
    def initialize(params = {})
      @links = params.delete(:links) || {}
      self.attributes = params
    end

    def attributes=(attrs = {})
      @attributes = attrs.with_indifferent_access
    end

    def save
      if persisted?
        connection.execute(Query::Update.new(self.class, self))
      else
        connection.execute(Query::Create.new(self.class, attributes))
      end
    end

    def destroy
      connection.execute(Query::Destroy.new(self.class, self))
    end

    protected

    def connection
      self.class.connection
    end

    def method_missing(method, *args, &block)
      if has_attribute?(method)
        attributes[method]
      else
        super
      end
    end

    def has_attribute?(attr_name)
      attributes.has_key?(attr_name)
    end

  end
end