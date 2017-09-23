module JsonApiClient
  module Associations
    class BaseAssociation
      attr_reader :attr_name, :klass, :options
      def initialize(attr_name, klass, options = {})
        @attr_name = attr_name
        @klass = klass
        @options = options
      end

      def association_class
        @association_class ||= Utils.compute_type(klass, options.fetch(:class_name) do
          attr_name.to_s.classify
        end)
      end

      def query_builder(url)
        association_class.query_builder.new(
          association_class,
          association_class.requestor_class.new(association_class, url)
        )
      end

      def data(url)
        query_builder(url)
      end
    end
  end
end
