require 'forwardable'
require 'active_support/all'

module JsonApiClient
  class Resource
    attr_accessor :result_set
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
    include Helpers::CustomHeaders
    include Helpers::Inspectable

  end
end
