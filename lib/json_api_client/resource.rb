require 'forwardable'
module JsonApiClient
  class Resource

    class << self
      extend Forwardable
      def_delegators :new_query, :where, :order, :includes, :all

      def new_query
        Query.new(self)
      end

      def table_name
        name.demodulize.underscore.pluralize
      end

      def primary_key
        :id
      end
    end

    attr_reader :links
    def initialize(params = {})
      @links = params.delete(:links) || {}
      self.attributes = params
    end

    def attributes=(attrs = {})
      @attributes = attrs
    end

    def save
      raise "not implemented"
    end

    def destroy
      raise "not implemented"
    end

  end
end