require 'forwardable'
require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class/attribute'

module JsonApiClient
  class Resource
    class_attribute :site, :primary_key, :link_style, :default_headers

    self.primary_key = :id
    self.link_style = :id # or :url
    self.default_headers = {}

    class << self
      # base URL for this resource
      def resource
        File.join(site, path)
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
        if result.has_errors?
          if block_given?
            yield result
          else
            return nil
          end
        end
        result.first
      end

      def run_request(query)
        parse(connection.execute(query))
      end
    end

    include Helpers::Initializable
    include Helpers::Attributable
    include Helpers::Associable
    include Helpers::Parsable
    include Helpers::Queryable
    include Helpers::Serializable
    include Helpers::Linkable

    def save
      query = persisted? ? 
        Query::Update.new(self.class, attributes) :
        Query::Create.new(self.class, attributes)

      run_request(query)
    end

    def destroy
      run_request(Query::Destroy.new(self.class, attributes))
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