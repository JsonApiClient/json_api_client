module JsonApiClient
  module Helpers
    module Associatable
      extend ActiveSupport::Concern

      included do
        class_attribute :associations, instance_accessor: false
        self.associations = []
        attr_accessor :__cached_associations
        attr_accessor :__belongs_to_params
      end

      module ClassMethods
        def _define_association(attr_name, association_klass, options = {})
          attr_name = attr_name.to_sym
          association = association_klass.new(attr_name, self, options)
          self.associations += [association]
        end

        def _define_relationship_methods(attr_name)
          attr_name = attr_name.to_sym

          define_method(attr_name) do
            _cached_relationship(attr_name) do
              relationship_definition = relationship_definition_for(attr_name)
              return unless relationship_definition
              relationship_data_for(attr_name, relationship_definition)
            end
          end

          define_method("#{attr_name}=") do |value|
            _clear_cached_relationship(attr_name)
            relationships.public_send("#{attr_name}=", value)
          end
        end

        def belongs_to(attr_name, options = {})
          _define_association(attr_name, JsonApiClient::Associations::BelongsTo::Association, options)

          param = associations.last.param
          define_method(param) do
            _belongs_to_params[param]
          end

          define_method(:"#{param}=") do |value|
            _belongs_to_params[param] = value
          end
        end

        def has_many(attr_name, options = {})
          _define_association(attr_name, JsonApiClient::Associations::HasMany::Association, options)
          _define_relationship_methods(attr_name)
        end

        def has_one(attr_name, options = {})
          _define_association(attr_name, JsonApiClient::Associations::HasOne::Association, options)
          _define_relationship_methods(attr_name)
        end
      end

      def _belongs_to_params
        self.__belongs_to_params ||= {}
      end

      def _clear_belongs_to_params
        self.__belongs_to_params = {}
      end

      def _cached_associations
        self.__cached_associations ||= {}
      end

      def _clear_cached_relationships
        self.__cached_associations = {}
      end

      def _clear_cached_relationship(attr_name)
        _cached_associations.delete(attr_name)
      end

      def _cached_relationship(attr_name)
        return _cached_associations[attr_name] if _cached_associations.has_key?(attr_name)
        _cached_associations[attr_name] = yield
      end

    end
  end
end
