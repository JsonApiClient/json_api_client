require 'forwardable'
require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute'

module JsonApiClient
  class Resource
    class_attribute :site, :primary_key, :link_style, :default_headers
    class_attribute :initializers

    self.primary_key = :id
    self.link_style = :id # or :url
    self.default_headers = {}
    self.initializers = []

    class << self
      # first 'scope' should build a new scope object
      extend Forwardable
      def_delegators :new_scope, :where, :order, :includes, :all, :paginate, :page, :first

      # base URL for this resource
      def resource
        File.join(site, table_name)
      end

      def table_name
        resource_name.pluralize
      end

      def resource_name
        name.demodulize.underscore
      end

      def find(conditions)
        run_request(Query::Find.new(self, conditions))
      end

      def create(conditions = {})
        result = run_request(Query::Create.new(self, conditions))
        return nil if result.errors.length > 0
        result.first
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

      def run_request(query)
        parse(connection.execute(query))
      end

      private

      def new_scope
        Scope.new(self)
      end

      def parser
        Parser
      end

      def parse(data)
        parser.parse(self, data)
      end

      def build_connection
        Connection.new(site)
      end

      def initialize(method = nil, &block)
        self.initializers.push(method || block)
      end
    end

    include Attributes
    include Associations
    include Links

    attr_accessor :errors
    def initialize(params = {})
      initializers.each do |initializer|
        if initializer.respond_to?(:call)
          initializer.call(self, params)
        else
          self.send(initializer, params)
        end
      end
    end

    def save
      query = persisted? ? 
        Query::Update.new(self.class, self) :
        Query::Create.new(self.class, attributes)

      run_request(query)
    end

    def destroy
      run_request(Query::Destroy.new(self.class, self))
    end

    protected

    def run_request(query)
      response = self.class.run_request(query)
      self.errors = response.errors
      if updated = response.first
        self.attributes = updated.attributes
      else
        self.attributes = {}
      end
      return errors.length == 0
    end

  end
end