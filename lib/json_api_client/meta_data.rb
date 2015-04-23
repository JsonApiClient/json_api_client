module JsonApiClient
  class MetaData

    def initialize(data)
      @data = data
    end

    def respond_to?(name)
      @data.has_key?(name.to_s) || super
    end

    def method_missing(name, *args)
      if @data.has_key?(name.to_s)
        @data[name.to_s]
      else
        super
      end
    end

  end
end