module JsonApiClient
  class ErrorCollector < Array
    class Error
      delegate :[], to: :attrs

      def initialize(attrs = {})
        @attrs = (attrs || {}).with_indifferent_access
      end

      def id
        attrs[:id]
      end

      def about
        res = attrs.fetch(:links, {})
        res ? res[:about] : {}
      end

      def status
        attrs[:status]
      end

      def code
        attrs[:code]
      end

      def title
        attrs[:title]
      end

      def detail
        attrs[:detail]
      end

      def source_parameter
        source[:parameter]
      end

      def source_pointer
        source[:pointer]
      end

      def error_key
        if source_pointer && source_pointer != "/data"
          source_pointer.split("/").last
        else
          "base"
        end
      end

      def error_msg
        msg = title || detail || "invalid"
        if source_parameter
          "#{source_parameter} #{msg}"
        else
          msg
        end
      end

      def source
        res = attrs.fetch(:source, {})
        res ? res : {}
      end

      def meta
        MetaData.new(attrs.fetch(:meta, {}))
      end

      protected

      attr_reader :attrs
    end

    def initialize(error_data)
      super(error_data.map do |data|
        Error.new(data)
      end)
    end

    def full_messages
      map(&:title)
    end

    def [](source)
      map do |error|
        error.error_key == source
      end
    end

  end
end
