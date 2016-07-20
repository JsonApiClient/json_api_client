module JsonApiClient
  class MetaData
    include Helpers::DynamicAttributes

    attr_accessor :record_class

    def initialize(data, record_class = nil)
      self.record_class = record_class
      self.attributes = data
    end

    protected

    def key_formatter
      record_class && record_class.key_formatter
    end

  end
end
