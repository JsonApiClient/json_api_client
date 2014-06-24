module JsonApiClient
  class Link
    attr_accessor :type

    def initialize(type, spec)
      @type = type
      @spec = spec
    end

  end
end