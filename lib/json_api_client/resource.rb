require 'forwardable'
require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/deprecation'
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

      def find(*args)
        conditions = args.extract_options!
        keys = args.flatten
        if keys.one? && conditions.blank?
          find_one(keys.first)
        elsif keys.present? && conditions.blank?
          run_request(Query::Find.new(self, Array(keys)))
        else
          conditions.merge!({
            self.primary_key.to_sym => keys
          })
          run_request(Query::Find.new(self, conditions))
        end
      end
      
      def find_one(key)
        response = run_request(Query::Find.new(self, key)).try(:first)
        raise Errors::NotFound, "Couldn't find #{self.class.name} with primary key #{key}" unless response.present?
        response
      end

      def create(conditions = {})
        result = run_request(Query::Create.new(self, conditions))
        if result.has_errors?
          yield(result) if block_given?
          return nil
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
    include Helpers::CustomEndpoints

    def save
      query = persisted? ? 
        Query::Update.new(self.class, attributes) :
        Query::Create.new(self.class, attributes)

      run_request(query)
    end

    def destroy
      if run_request(Query::Destroy.new(self.class, attributes))
        self.attributes.clear
        true
      else
        false
      end
    end

    # For backwards compatibility
    def first
      self
    end

    protected


    def run_request(query)
      # reset errors if a new request is being made
      self.errors.clear if self.errors
      
      result = self.class.run_request(query)
      self.errors = result.errors
      if result.has_errors?
        return false
      else
        if updated = result.first
          self.attributes = updated.attributes
        end
        return true
      end
    end

  end
end