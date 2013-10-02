module JsonApiClient
  class Scope
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @params = {}
      @pagination = {}
      @includes = []
      @order = nil
    end

    def where(conditions = {})
      @params.merge!(conditions)
      self
    end

    def order(conditions)
      where(order: conditions)
    end

    def includes(tables)
      @params[:includes]
      @includes += Array(tables)
      self
    end

    def paginate(conditions)
      @pagination.merge!(conditions)
      self
    end

    def page(number)
      paginate(page: number)
    end

    def params
      result = @params.merge(@pagination)
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
