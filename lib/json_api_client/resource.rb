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
    include Helpers::Associatable

    attr_accessor :last_result_set,
                  :links,
                  :relationships,
                  :request_params
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
                    :json_key_format,
                    :route_format,
                    :request_params_class,
                    :keep_request_params,
                    :search_included_in_result_set,
                    :custom_type_to_class,
                    :raise_on_blank_find_param,
                    instance_accessor: false
    class_attribute :add_defaults_to_changes,
                    instance_writer: false

    class_attribute :_immutable,
                    instance_writer: false,
                    default: false

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
    self.request_params_class = RequestParams
    self.keep_request_params = false
    self.add_defaults_to_changes = false
    self.search_included_in_result_set = false
    self.custom_type_to_class = {}
    self.raise_on_blank_find_param = false

    #:underscored_key, :camelized_key, :dasherized_key, or custom
    self.json_key_format = :underscored_key

    #:underscored_route, :camelized_route, :dasherized_route, or custom
    self.route_format = :underscored_route

    class << self
      extend Forwardable
      def_delegators :_new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :with_params, :first, :find, :last

      def resolve_custom_type(type_name, class_name)
        classified_type = key_formatter.unformat(type_name.to_s).singularize.classify
        self.custom_type_to_class = custom_type_to_class.merge(classified_type => class_name.to_s)
      end

      # The table name for this resource. i.e. Article -> articles, Person -> people
      #
      # @return [String] The table name for this resource
      def table_name
        route_formatter.format(resource_name.pluralize)
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

      # Indicates whether this resource is mutable or immutable;
      # by default, all resources are mutable.
      #
      # @return [Boolean]
      def immutable(flag = true)
        self._immutable = flag
      end

      def inherited(subclass)
        subclass._immutable = false
        super
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
          resource.relationships.clear_changes_information
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
        if params && _prefix_path.present?
          path_params = params.delete(:path) || params
          parts.unshift(_set_prefix_path(path_params.symbolize_keys))
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
        return _header_store.to_h if superclass == Object

        superclass.custom_headers.merge(_header_store.to_h)
      end

      # Returns the requestor for this resource class
      #
      # @return [Requestor] The requestor for this resource class
      def requestor
        @requestor ||= requestor_class.new(self)
      end

      # Default attributes that every instance of this resource should be
      # initialized with. Optionally, override this method in a subclass.
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

      def key_formatter
        JsonApiClient::Formatter.formatter_for(json_key_format)
      end

      def route_formatter
        JsonApiClient::Formatter.formatter_for(route_format)
      end

      protected

      # Declares a new class/instance method that acts on the collection/member
      #
      # @param name [Symbol] the name of the endpoint
      # @param options [Hash] endpoint options
      # @option [Symbol] :on One of [:collection or :member] to decide whether it's a collect or member method
      # @option [Symbol] :request_method The request method (:get, :post, etc)
      def custom_endpoint(name, options = {})
        if _immutable
          request_method = options.fetch(:request_method, :get).to_sym
          raise JsonApiClient::Errors::ResourceImmutableError if request_method != :get
        end

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
        define_method(name) do
          attributes[name]
        end
        define_method("#{name}=") do |value|
          set_attribute(name, value)
        end
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
        paths = _belongs_to_associations.map do |a|
          a.to_prefix_path(route_formatter)
        end

        paths.join("/")
      end

      def _set_prefix_path(attrs)
        paths = _belongs_to_associations.map do |a|
          a.set_prefix_path(attrs, route_formatter)
        end

        paths.join("/")
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
      params = params.symbolize_keys
      @persisted = nil
      @destroyed = nil
      self.links = self.class.linker.new(params.delete(:links) || {})
      self.relationships = self.class.relationship_linker.new(self.class, params.delete(:relationships) || {})
      self.attributes = self.class.default_attributes.merge params.except(*self.class.prefix_params)
      self.forget_change!(:type)
      self.__belongs_to_params = params.slice(*self.class.prefix_params)

      setup_default_properties

      self.class.associations.each do |association|
        if params.has_key?(association.attr_name.to_s)
          set_attribute(association.attr_name, params[association.attr_name.to_s])
        end
      end
      self.request_params = self.class.request_params_class.new(self.class)
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
      !!@persisted && !destroyed? && has_attribute?(self.class.primary_key)
    end

    # Mark the record as destroyed
    def mark_as_destroyed!
      @destroyed = true
    end

    # Whether or not this record has been destroyed to the database previously
    #
    # @return [Boolean]
    def destroyed?
      !!@destroyed
    end

    # Returns true if this is a new record (never persisted to the database)
    #
    # @return [Boolean]
    def new_record?
      !persisted? && !destroyed?
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
      attributes.slice(self.class.primary_key, :type).tap do |h|
        relationships_for_serialization.tap do |r|
          h[:relationships] = self.class.key_formatter.format_keys(r) unless r.empty?
        end
        h[:attributes] = self.class.key_formatter.format_keys(attributes_for_serialization)
      end
    end

    def as_json(*)
      attributes.slice(self.class.primary_key, :type).tap do |h|
        relationships.as_json.tap do |r|
          h[:relationships] = r unless r.empty?
        end
        h[:attributes] = attributes.except(self.class.primary_key, :type).as_json
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
      raise JsonApiClient::Errors::ResourceImmutableError if _immutable

      self.last_result_set = if persisted?
        self.class.requestor.update(self)
      else
        self.class.requestor.create(self)
      end

      if last_result_set.has_errors?
        fill_errors
        false
      else
        self.errors.clear if self.errors
        self.request_params.clear unless self.class.keep_request_params
        mark_as_persisted!
        if updated = last_result_set.first
          self.attributes = updated.attributes
          self.links.attributes = updated.links.attributes
          self.relationships.attributes = updated.relationships.attributes
          clear_changes_information
          self.relationships.clear_changes_information
          _clear_cached_relationships
        end
        true
      end
    end

    # Try to destroy this resource
    #
    # @return [Boolean] Whether or not the destroy succeeded
    def destroy
      raise JsonApiClient::Errors::ResourceImmutableError if _immutable

      self.last_result_set = self.class.requestor.destroy(self)
      if last_result_set.has_errors?
        fill_errors
        false
      else
        mark_as_destroyed!
        _clear_cached_relationships
        _clear_belongs_to_params
        true
      end
    end

    def inspect
      "#<#{self.class.name}:@attributes=#{attributes.inspect}>"
    end

    def request_includes(*includes)
      self.request_params.add_includes(includes)
      self
    end

    def reset_request_includes!
      self.request_params.reset_includes!
      self
    end

    def request_select(*fields)
      fields_by_type = fields.extract_options!
      fields_by_type[type.to_sym] = fields if fields.any?
      fields_by_type.each do |field_type, field_names|
        self.request_params.set_fields(field_type, field_names)
      end
      self
    end

    def reset_request_select!(*resource_types)
      resource_types = self.request_params.field_types if resource_types.empty?
      resource_types.each { |resource_type| self.request_params.remove_fields(resource_type) }
      self
    end

    def path_attributes
      _belongs_to_params.merge attributes.slice( self.class.primary_key ).symbolize_keys
    end

    protected

    def setup_default_properties
      self.class.schema.each_property do |property|
        unless attributes.has_key?(property.name) || property.default.nil?
          attribute_will_change!(property.name) if add_defaults_to_changes
          attributes[property.name] = property.default
        end
      end
    end

    def relationship_definition_for(name)
      relationships[name] if relationships && relationships.has_attribute?(name)
    end

    def included_data_for(name, relationship_definition)
      last_result_set.included.data_for(name, relationship_definition)
    end

    def relationship_data_for(name, relationship_definition)
      # look in included data
      if relationship_definition.key?("data")
        if relationships.attribute_changed?(name)
          return relation_objects_for(name, relationship_definition)
        else
          return included_data_for(name, relationship_definition)
        end
      end

      return unless links = relationship_definition["links"]
      return unless url = links["related"]

      association_for(name).data(url)
    end

    def relation_objects_for(name, relationship_definition)
      data = relationship_definition["data"]
      assoc = association_for(name)
      return if data.nil? || assoc.nil?
      assoc.load_records(data)
    end

    def method_missing(method, *args)
      relationship_definition = relationship_definition_for(method)

      return super unless relationship_definition

      relationship_data_for(method, relationship_definition)
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
        association.attr_name.to_s == self.class.key_formatter.unformat(name)
      end
    end

    def non_serializing_attributes
      self.class.read_only_attributes
    end

    def attributes_for_serialization
      attributes.except(*non_serializing_attributes).slice(*changed)
    end

    def relationships_for_serialization
      relationships.as_json_api
    end

    def error_message_for(error)
      error.error_msg
    end

    def fill_errors
      last_result_set.errors.each do |error|
        key = self.class.key_formatter.unformat(error.error_key)
        errors.add(key, error_message_for(error))
      end
    end
  end
end
