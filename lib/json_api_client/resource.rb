require 'forwardable'
require 'active_support/all'
require 'active_model'

module JsonApiClient
  class Resource
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion

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
      def_delegators :new_scope, :where, :order, :includes, :select, :all, :paginate, :page, :first, :find

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

      def load(params)
        new(params).tap do |resource|
          resource.mark_as_persisted!
          resource.clear_changes_information
        end
      end

      def connection(rebuild = false, &block)
        build_connection(&block)
        connection_object
      end

      def prefix_params
        _belongs_to_associations.map(&:param)
      end

      def prefix_path
        _belongs_to_associations.map(&:to_prefix_path).join("/")
      end

      def path(params = nil)
        parts = [table_name]
        if params
          path_params = params.delete(:path) || params
          parts.unshift(prefix_path % path_params.symbolize_keys)
        else
          parts.unshift(prefix_path)
        end
        parts.reject!{|part| part == "" }
        File.join(*parts)
      rescue KeyError
        raise ArgumentError, "Not all prefix parameters specified"
      end

      def create(conditions = {})
        new(conditions).tap do |resource|
          resource.save
        end
      end

      def with_headers(headers)
        self.custom_headers = headers
        yield
      ensure
        self.custom_headers = {}
      end

      def custom_headers
        header_store
      end

      def requestor
        @requestor ||= requestor_class.new(self)
      end

      def default_attributes
        {type: table_name}
      end

      # Returns the schema for this resource class
      #
      # @return [Schema] the schema for this resource class
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

      def new_scope
        query_builder.new(self)
      end

      def custom_headers=(headers)
        header_store.replace(headers)
      end

      def header_store
        Thread.current["json_api_client-#{resource_name}"] ||= {}
      end

      def build_connection(rebuild = false)
        return connection_object unless connection_object.nil? || rebuild
        self.connection_object = connection_class.new(connection_options.merge(site: site)).tap do |conn|
          yield(conn) if block_given?
        end
      end
    end

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
        attributes[property.name] = property.default unless attributes.has_key?(property.name)
      end
    end

    def update_attributes(attrs = {})
      self.attributes = attrs
      save
    end

    def mark_as_persisted!
      @persisted = true
    end

    def persisted?
      !!@persisted && has_attribute?(self.class.primary_key)
    end

    def to_param
      attributes.fetch(self.class.primary_key, "").to_s
    end

    def as_relation
      {
        :type => self.class.table_name,
        self.class.primary_key => self[self.class.primary_key]
      }
    end

    def serializable_hash
      attributes.slice('id', 'type').tap do |h|
        relationships_for_serialization.tap do |r|
          h['relationships'] = r unless r.empty?
        end
        h['attributes'] = attributes_for_serialization
      end
    end

    def set_all_dirty!
      set_all_attributes_dirty
      relationships.set_all_attributes_dirty if relationships
    end

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
        end
        true
      end
    end

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
      return super unless relationships && relationships.has_attribute?(method) && last_result_set.included
      last_result_set.included.data_for(method, relationships[method])
    end

    def respond_to_missing?(symbol, include_all = false)
      return true if relationships && relationships.has_attribute?(symbol)
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

    def attributes_for_serialization
      attributes.except(*self.class.read_only_attributes).slice(*changed)
    end

    def relationships_for_serialization
      relationships.serializable_hash
    end
  end
end
