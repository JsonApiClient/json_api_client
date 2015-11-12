require 'forwardable'
require 'active_support/all'
require 'active_model'

module JsonApiClient
  class Resource
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Serialization

    include Helpers::DynamicAttributes
    include Helpers::Dirty

    attr_accessor :last_result_set,
                  :links,
                  :relationships
    class_attribute :site,
                    :primary_key,
                    :parser,
                    :paginator,
                    :connection_class,
                    :connection_object,
                    :connection_options,
                    :query_builder,
                    :linker,
                    :relationship_linker,
                    :read_only_attributes,
                    :requestor_class,
                    :associations,
                    instance_accessor: false
    self.primary_key          = :id
    self.parser               = Parsers::Parser
    self.paginator            = Paginating::Paginator
    self.connection_class     = Connection
    self.connection_options   = {}
    self.query_builder        = Query::Builder
    self.linker               = Linking::Links
    self.relationship_linker  = Relationships::Relations
    self.read_only_attributes = [:id, :type, :links, :meta, :relationships]
    self.requestor_class      = Query::Requestor
    self.associations         = []

    include Associations::BelongsTo
    include Associations::HasMany
    include Associations::HasOne

    class << self
      extend Forwardable
      def_delegators :_new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :with_params, :first, :find

      # The table name for this resource. i.e. Article -> articles, Person -> people
      #
      # @return [String] The table name for this resource
      def table_name
        JsonApiClient.configuration.route_formatter.format(resource_name.pluralize)
      end

      # The name of a single resource. i.e. Article -> article, Person -> person
      #
      # @return [String]
      def resource_name
        name.demodulize.underscore
      end

      # Specifies the JSON API resource type. By default this is inferred
      # from the resource class name.
      #
      # @return [String] Resource path
      def type
        table_name
      end

      # Specifies the relative path that should be used for this resource;
      # by default, this is inferred from the resource class name.
      #
      # @return [String] Resource path
      def resource_path
        table_name
      end

      # Load a resource object from attributes and consider it persisted
      #
      # @return [Resource] Persisted resource object
      def load(params)
        new(params).tap do |resource|
          resource.mark_as_persisted!
          resource.clear_changes_information
        end
      end

      # Return/build a connection object
      #
      # @return [Connection] The connection to the json api server
      def connection(rebuild = false, &block)
        _build_connection(rebuild, &block)
        connection_object
      end

      # Param names that will be considered path params. They will be used
      # to build the resource path rather than treated as attributes
      #
      # @return [Array] Param name symbols of parameters that will be treated as path parameters
      def prefix_params
        _belongs_to_associations.map(&:param)
      end

      # Return the path or path pattern for this resource
      def path(params = nil)
        parts = [resource_path]
        if params
          path_params = params.delete(:path) || params
          parts.unshift(_prefix_path % path_params.symbolize_keys)
        else
          parts.unshift(_prefix_path)
        end
        parts.reject!(&:blank?)
        File.join(*parts)
      rescue KeyError
        raise ArgumentError, "Not all prefix parameters specified"
      end

      # Create a new instance of this resource class
      #
      # @param attributes [Hash] The attributes to create this resource with
      # @return [Resource] The instance you tried to create. You will have to check the persisted state or errors on this object to see success/failure.
      def create(attributes = {})
        new(attributes).tap do |resource|
          resource.save
        end
      end

      # Within the given block, add these headers to all requests made by
      # the resource class
      #
      # @param headers [Hash] The headers to send along
      # @param block [Block] The block where headers will be set for
      def with_headers(headers)
        self._custom_headers = headers
        yield
      ensure
        self._custom_headers = {}
      end

      # The current custom headers to send with any request made by this
      # resource class
      #
      # @return [Hash] Headers
      def custom_headers
        _header_store.to_h
      end

      # Returns the requestor for this resource class
      #
      # @return [Requestor] The requestor for this resource class
      def requestor
        @requestor ||= requestor_class.new(self)
      end

      # Default attributes that every instance of this resource should be
      # intialized with. Optionally, override this method in a subclass.
      #
      # @return [Hash] Default attributes
      def default_attributes
        {type: type}
      end

      # Returns the schema for this resource class
      #
      # @return [Schema] The schema for this resource class
      def schema
        @schema ||= Schema.new
      end

      protected

      # Declares a new class/instance method that acts on the collection/member
      #
      # @param name [Symbol] the name of the endpoint
      # @param options [Hash] endpoint options
      # @option [Symbol] :on One of [:collection or :member] to decide whether it's a collect or member method
      # @option [Symbol] :request_method The request method (:get, :post, etc)
      def custom_endpoint(name, options = {})
        if :collection == options.delete(:on)
          collection_endpoint(name, options)
        else
          member_endpoint(name, options)
        end
      end

      # Declares a new class method that acts on the collection
      #
      # @param name [Symbol] the name of the endpoint and the method name
      # @param options [Hash] endpoint options
      # @option options [Symbol] :request_method The request method (:get, :post, etc)
      def collection_endpoint(name, options = {})
        metaclass = class << self
          self
        end
        metaclass.instance_eval do
          define_method(name) do |*params|
            request_params = params.first || {}
            requestor.custom(name, options, request_params)
          end
        end
      end

      # Declares a new instance method that acts on the member object
      #
      # @param name [Symbol] the name of the endpoint and the method name
      # @param options [Hash] endpoint options
      # @option options [Symbol] :request_method The request method (:get, :post, etc)
      def member_endpoint(name, options = {})
        define_method name do |*params|
          request_params = params.first || {}
          request_params[self.class.primary_key] = attributes.fetch(self.class.primary_key)
          self.class.requestor.custom(name, options, request_params)
        end
      end

      # Declares a new property by name
      #
      # @param name [Symbol] the name of the property
      # @param options [Hash] property options
      # @option options [Symbol] :type The property type
      # @option options [Symbol] :default The default value for the property
      def property(name, options = {})
        schema.add(name, options)
      end

      # Declare multiple properties with the same optional options
      #
      # @param [Array<Symbol>] names
      # @param options [Hash] property options
      # @option options [Symbol] :type The property type
      # @option options [Symbol] :default The default value for the property
      def properties(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}
        names.each do |name|
          property name, options
        end
      end

      def _belongs_to_associations
        associations.select{|association| association.is_a?(Associations::BelongsTo::Association) }
      end

      def _prefix_path
        _belongs_to_associations.map(&:to_prefix_path).join("/")
      end

      def _new_scope
        query_builder.new(self)
      end

      def _custom_headers=(headers)
        _header_store.replace(headers)
      end

      def _header_store
        Thread.current["json_api_client-#{resource_name}"] ||= {}
      end

      def _build_connection(rebuild = false)
        return connection_object unless connection_object.nil? || rebuild
        self.connection_object = connection_class.new(connection_options.merge(site: site)).tap do |conn|
          yield(conn) if block_given?
        end
      end
    end

    # Instantiate a new resource object
    #
    # @param params [Hash] Attributes, links, and relationships
    def initialize(params = {})
      self.links = self.class.linker.new(params.delete("links") || {})
      self.relationships = self.class.relationship_linker.new(params.delete("relationships") || {})
      self.class.associations.each do |association|
        if params.has_key?(association.attr_name.to_s)
          set_attribute(association.attr_name, association.parse(params[association.attr_name.to_s]))
        end
      end
      self.attributes = params.merge(self.class.default_attributes)
      self.class.schema.each_property do |property|
        attributes[property.name] = property.default unless attributes.has_key?(property.name) || property.default.nil?
      end
    end

    # Set the current attributes and try to save them
    #
    # @param attrs [Hash] Attributes to update
    # @return [Boolean] Whether the update succeeded or not
    def update_attributes(attrs = {})
      self.attributes = attrs
      save
    end

    # Alias to update_attributes
    #
    # @param attrs [Hash] Attributes to update
    # @return [Boolean] Whether the update succeeded or not
    def update(attrs = {})
      update_attributes(attrs)
    end

    # Mark the record as persisted
    def mark_as_persisted!
      @persisted = true
    end

    # Whether or not this record has been persisted to the database previously
    #
    # @return [Boolean]
    def persisted?
      !!@persisted && has_attribute?(self.class.primary_key)
    end

    # Returns true if this is a new record (never persisted to the database)
    #
    # @return [Boolean]
    def new_record?
      !persisted?
    end

    # When we represent this resource as a relationship, we do so with id & type
    #
    # @return [Hash] Representation of this object as a relation
    def as_relation
      attributes.slice(:type, self.class.primary_key)
    end

    # When we represent this resource for serialization (create/update), we do so
    # with this implementation
    #
    # @return [Hash] Representation of this object as JSONAPI object
    def as_json_api(*)
      attributes.slice(:id, :type).tap do |h|
        relationships_for_serialization.tap do |r|
          h[:relationships] = r unless r.empty?
        end
        h[:attributes] = attributes_for_serialization
      end
    end

    def as_json(*)
      attributes.slice(:id, :type).tap do |h|
        relationships.as_json.tap do |r|
          h[:relationships] = r unless r.empty?
        end
        h[:attributes] = attributes.except(:id, :type).as_json
      end
    end

    # Mark all attributes for this record as dirty
    def set_all_dirty!
      set_all_attributes_dirty
      relationships.set_all_attributes_dirty if relationships
    end

    def valid?(context = nil)
      context ||= (new_record? ? :create : :update)
      super(context)
    end

    # Commit the current changes to the resource to the remote server.
    # If the resource was previously loaded from the server, we will
    # try to update the record. Otherwise if it's a new record, then
    # we will try to create it
    #
    # @return [Boolean] Whether or not the save succeeded
    def save
      return false unless valid?

      self.last_result_set = if persisted?
        self.class.requestor.update(self)
      else
        self.class.requestor.create(self)
      end

      if last_result_set.has_errors?
        last_result_set.errors.each do |error|
          if error.source_parameter
            errors.add(error.source_parameter, error.title)
          else
            errors.add(:base, error.title)
          end
        end
        false
      else
        self.errors.clear if self.errors
        mark_as_persisted!
        if updated = last_result_set.first
          self.attributes = updated.attributes
          self.relationships.attributes = updated.relationships.attributes
          clear_changes_information
        end
        true
      end
    end

    # Try to destroy this resource
    #
    # @return [Boolean] Whether or not the destroy succeeded
    def destroy
      self.last_result_set = self.class.requestor.destroy(self)
      if !last_result_set.has_errors?
        self.attributes.clear
        true
      else
        false
      end
    end

    def inspect
      "#<#{self.class.name}:@attributes=#{attributes.inspect}>"
    end

    protected

    def method_missing(method, *args)
      association = association_for(method)

      return super unless association || (relationships && relationships.has_attribute?(method))

      return nil unless relationship_definitions = relationships[method]

      # look in included data
      if relationship_definitions.key?("data")
        return last_result_set.included.data_for(method, relationship_definitions)
      end

      if association = association_for(method)
        # look for a defined relationship url
        if relationship_definitions["links"] && url = relationship_definitions["links"]["related"]
          return association.data(url)
        end
      end
      nil
    end

    def respond_to_missing?(symbol, include_all = false)
      return true if relationships && relationships.has_attribute?(symbol)
      return true if association_for(symbol)
      super
    end

    def set_attribute(name, value)
      property = property_for(name)
      value = property.cast(value) if property
      super(name, value)
    end

    def has_attribute?(attr_name)
      !!property_for(attr_name) || super
    end

    def property_for(name)
      self.class.schema.find(name)
    end

    def association_for(name)
      self.class.associations.detect do |association|
        association.attr_name.to_s == JsonApiClient.configuration.key_formatter.unformat(name)
      end
    end

    def attributes_for_serialization
      attributes.except(*self.class.read_only_attributes).slice(*changed)
    end

    def relationships_for_serialization
      relationships.as_json_api
    end
  end
end
