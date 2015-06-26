require 'forwardable'
require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/enumerable'

module JsonApiClient
  class Resource
    class_attribute :site, :primary_key
    self.primary_key = :id

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
    end

    include Helpers::Initializable
    include Helpers::Attributable
    include Helpers::Associable
    include Helpers::Parsable
    include Helpers::Queryable
    include Helpers::Serializable
    include Helpers::Linkable
    include Helpers::Relatable
    include Helpers::CustomEndpoints
    include Helpers::Schemable
    include Helpers::Paginatable
    include Helpers::Requestable

  end
end
