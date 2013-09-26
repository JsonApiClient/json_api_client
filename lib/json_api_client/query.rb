module JsonApiClient
  class Query

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

    def all
      self
    end

    def to_a
      klass.connection.execute(self)
    end

  end
end
