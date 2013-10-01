module JsonApiClient
  class Scope
    attr_reader :klass, :params

    def initialize(klass)
      @klass = klass
      @params = {}
      @includes = []
      @order = nil
    end

    def where(conditions = {})
      @params.merge!(conditions)
      self
    end

    def order(conditions)
      @order = conditions
      self
    end

    def includes(tables)
      @includes += Array(tables)
      self
    end

    def build
      klass.new(params)
    end

    def to_a
      klass.find(params)
    end
    alias all to_a

  end
end
