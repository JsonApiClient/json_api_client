module JsonApiClient
  module Query
    class Builder

      attr_reader :klass, :path_params

      def initialize(klass)
        @klass = klass
        @primary_key = nil
        @pagination_params = {}
        @path_params = {}
        @filters = {}
        @includes = []
        @orders = []
        @fields = []
      end

      def where(conditions = {})
        # pull out any path params here
        @path_params.merge!(conditions.slice(*klass.prefix_params))
        @filters.merge!(conditions.except(*klass.prefix_params))
        self
      end

      def order(*args)
        @orders += parse_orders(*args)
        self
      end

      def includes(*tables)
        @includes += parse_related_links(*tables)
        self
      end

      def select(fields)
        @fields += fields.split(",").map(&:strip)
        self
      end

      def paginate(conditions = {})
        scope = self
        scope = scope.page(conditions[:page]) if conditions[:page]
        scope = scope.per(conditions[:per_page]) if conditions[:per_page]
        scope
      end

      def page(number)
        @pagination_params[:number] = number
        self
      end

      def per(size)
        @pagination_params[:size] = size
        self
      end

      def first
        paginate(page: 1, per_page: 1).to_a.first
      end

      def build
        klass.new(params)
      end

      def params
        filter_params
          .merge(pagination_params)
          .merge(includes_params)
          .merge(order_params)
          .merge(select_params)
          .merge(primary_key_params)
          .merge(path_params)
      end

      def to_a
        @to_a ||= find
      end
      alias all to_a

      def find(args = {})
        case args
        when Hash
          where(args)
        else
          @primary_key = args
        end

        klass.requestor.get(params)
      end

      def method_missing(method_name, *args, &block)
        to_a.send(method_name, *args, &block)
      end

      private

      def path_params
        @path_params.empty? ? {} : {path: @path_params}
      end

      def primary_key_params
        return {} unless @primary_key

        @primary_key.is_a?(Array) ?
          {klass.primary_key.to_s.pluralize.to_sym => @primary_key.join(",")} :
          {klass.primary_key => @primary_key}
      end

      def pagination_params
        @pagination_params.empty? ? {} : {page: @pagination_params}
      end

      def includes_params
        @includes.empty? ? {} : {include: @includes.join(",")}
      end

      def filter_params
        @filters.empty? ? {} : {filter: @filters}
      end

      def order_params
        @orders.empty? ? {} : {sort: @orders.join(",")}
      end

      def select_params
        @fields.empty? ? {} : {fields: {klass.table_name => @fields.join(",")}}
      end

      def parse_related_links(*tables)
        tables.map do |table|
          case table
          when Hash
            table.map do |k, v|
              parse_related_links(*v).map do |sub|
                "#{k}.#{sub}"
              end
            end
          when Array
            table.map do |v|
              parse_related_links(*v)
            end
          else
            table
          end
        end.flatten
      end

      def parse_orders(*args)
        args.map do |arg|
          case arg
          when Hash
            arg.map do |k, v|
              operator = (v == :desc ? "-" : "")
              "#{operator}#{k}"
            end
          else
            "#{arg}"
          end
        end.flatten
      end

    end
  end
end
