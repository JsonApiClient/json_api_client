require 'active_support/all'

module JsonApiClient
  module Query
    class Builder

      attr_reader :klass
      delegate :key_formatter, to: :klass

      def initialize(klass, opts = {})
        @klass             = klass
        @primary_key       = opts.fetch( :primary_key, nil )
        @pagination_params = opts.fetch( :pagination_params, {} )
        @path_params       = opts.fetch( :path_params, {} )
        @additional_params = opts.fetch( :additional_params, {} )
        @filters           = opts.fetch( :filters, {} )
        @includes          = opts.fetch( :includes, [] )
        @orders            = opts.fetch( :orders, [] )
        @fields            = opts.fetch( :fields, [] )
      end

      def where(conditions = {})
        # pull out any path params here
        path_conditions = conditions.slice(*klass.prefix_params)
        unpathed_conditions = conditions.except(*klass.prefix_params)

        _new_scope( path_params: path_conditions, filters: unpathed_conditions )
      end

      def order(*args)
        _new_scope( orders: parse_orders(*args) )
      end

      def includes(*tables)
        _new_scope( includes: parse_related_links(*tables) )
      end

      def select(*fields)
        _new_scope( fields: parse_fields(*fields) )
      end

      def paginate(conditions = {})
        scope = _new_scope
        scope = scope.page(conditions[:page]) if conditions[:page]
        scope = scope.per(conditions[:per_page]) if conditions[:per_page]
        scope
      end

      def page(number)
        _new_scope( pagination_params: { klass.paginator.page_param => number || 1 } )
      end

      def per(size)
        _new_scope( pagination_params: { klass.paginator.per_page_param => size } )
      end

      def with_params(more_params)
        _new_scope( additional_params: more_params )
      end

      def first
        paginate(page: 1, per_page: 1).to_a.first
      end

      def last
        paginate(page: 1, per_page: 1).pages.last.to_a.last
      end

      def build(attrs = {})
        klass.new @path_params.merge(attrs.symbolize_keys)
      end

      def create(attrs = {})
        klass.create @path_params.merge(attrs.symbolize_keys)
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
        @to_a ||= _fetch
      end
      alias all to_a

      def find(args = {})
        if klass.raise_on_blank_find_param && args.blank?
          raise Errors::NotFound, 'blank .find param'
        end

        case args
        when Hash
          scope = where(args)
        else
          scope = _new_scope( primary_key: args )
        end

        scope._fetch
      end

      def method_missing(method_name, *args, &block)
        to_a.send(method_name, *args, &block)
      end

      def hash
        [
          klass,
          params
        ].hash
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        hash == other.hash
      end
      alias_method :eql?, :==

      protected

      def _fetch
        klass.requestor.get(params)
      end

      private

      def _new_scope( opts = {} )
        self.class.new( @klass,
             primary_key:       opts.fetch( :primary_key, @primary_key ),
             pagination_params: @pagination_params.merge( opts.fetch( :pagination_params, {} ) ),
             path_params:       @path_params.merge( opts.fetch( :path_params, {} ) ),
             additional_params: @additional_params.merge( opts.fetch( :additional_params, {} ) ),
             filters:           @filters.merge( opts.fetch( :filters, {} ) ),
             includes:          @includes + opts.fetch( :includes, [] ),
             orders:            @orders + opts.fetch( :orders, [] ),
             fields:            @fields + opts.fetch( :fields, [] ) )
      end

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
        if klass.paginator.ancestors.include?(Paginating::Paginator)
          # Original Paginator inconsistently wraps pagination params here. Keeping
          # default behavior for now so as not to break backward compatibility.
          @pagination_params.empty? ? {} : {page: @pagination_params}
        else
          @pagination_params
        end
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
