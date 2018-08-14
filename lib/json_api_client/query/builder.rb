module JsonApiClient
  module Query
    class Builder

      attr_reader :klass, :requestor
      delegate :key_formatter, to: :klass

      def initialize(klass, requestor = nil)
        @klass = klass
        @requestor = requestor || klass.requestor
        @primary_key = nil
        @pagination_params = {}
        @path_params = {}
        @additional_params = {}
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

      def select(*fields)
        @fields += parse_fields(*fields)
        self
      end

      def paginate(conditions = {})
        scope = self
        scope = scope.page(conditions[:page]) if conditions[:page]
        scope = scope.per(conditions[:per_page]) if conditions[:per_page]
        scope
      end

      def page(number)
        @pagination_params[ klass.paginator.page_param ] = number || 1
        self
      end

      def per(size)
        @pagination_params[ klass.paginator.per_page_param ] = size
        self
      end

      def with_params(more_params)
        @additional_params.merge!(more_params)
        self
      end

      def first
        paginate(page: 1, per_page: 1).to_a.first
      end

      def last
        paginate(page: 1, per_page: 1).pages.last.to_a.last
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
          .merge(additional_params)
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

        requestor.get(params)
      end

      def method_missing(method_name, *args, &block)
        to_a.send(method_name, *args, &block)
      end

      private

      def path_params
        @path_params.empty? ? {} : {path: @path_params}
      end

      def additional_params
        @additional_params
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
        if @fields.empty?
          {}
        else
          field_result = Hash.new { |h,k| h[k] = [] }
          @fields.each do |field|
            if field.is_a? Hash
              field.each do |k,v|
                field_result[k.to_s] << v
                field_result[k.to_s] = field_result[k.to_s].flatten
              end
            else
              field_result[klass.table_name] << field
            end
          end
          field_result.each { |k,v| field_result[k] = v.join(',') }
          {fields: field_result}
        end
      end

      def parse_related_links(*tables)
        Utils.parse_includes(klass, *tables)
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

      def parse_fields(*fields)
        fields = fields.split(',') if fields.is_a? String
        fields.map do |field|
          case field
          when Hash
            field.each do |k,v|
              field[k] = parse_fields(v)
            end
            field
          else
            Array(field).flatten.map { |i| i.to_s.split(",") }.flatten.map(&:strip)
          end
        end.flatten
      end

    end
  end
end
