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
      @to_a ||= klass.find(params)
    end
    alias all to_a

    def method_missing(method_name, *args, &block)
      to_a.send(method_name, *args, &block)
    end

  end
end
