module JsonApiClient
  class Scope
    attr_reader :klass, :params

    FIRST_PAGE_NUMBER = 1

    def initialize(klass)
      @klass = klass
      @params = {}
    end

    def where(conditions = {})
      @params.merge!(conditions)
      self
    end
    alias paginate where

    def order(conditions)
      where(order: conditions)
    end

    def includes(*tables)
      @params[:includes] ||= []
      @params[:includes] += tables.flatten
      self
    end

    def page(number)
      number = [number.to_i, FIRST_PAGE_NUMBER].max
      where(page: number)
    end

    def first
      paginate(page: FIRST_PAGE_NUMBER, per_page: 1).to_a.first
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
