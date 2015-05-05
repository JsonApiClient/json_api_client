module JsonApiClient
  class ErrorCollector
    class Error
      include Helpers::DynamicAttributes

      def initialize(attrs = {})
        attrs = {
          title: attrs
        } if attrs.is_a?(String)
        self.attributes = attrs
      end
    end

    attr_reader :errors
    extend Forwardable
    def_delegators :errors, :length, :present?

    def initialize(error_data)
      @errors = Array(error_data).map do |datum|
        Error.new(datum)
      end
    end

    def full_messages
      errors.map(&:title)
    end

  end
end