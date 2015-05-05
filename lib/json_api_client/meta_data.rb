module JsonApiClient
  class MetaData
    include Helpers::DynamicAttributes

    def initialize(data)
      self.attributes = data
    end

  end
end