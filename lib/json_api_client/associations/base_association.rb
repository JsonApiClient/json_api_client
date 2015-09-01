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

      def data(url)
        from_result_set(association_class.requestor.linked(url))
      end

      def from_result_set(result_set)
        result_set.to_a
      end
    end
  end
end