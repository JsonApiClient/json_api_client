module JsonApiClient
  module Utils

    def self.compute_type(klass, type_name)
      return klass.custom_type_to_class.fetch(type_name).constantize if klass.custom_type_to_class.key?(type_name)
      # If the type is prefixed with a scope operator then we assume that
      # the type_name is an absolute reference.
      return type_name.constantize if type_name.match(/^::/)

      # Build a list of candidates to search for
      candidates = []
      klass.name.scan(/::|$/) { candidates.unshift "#{$`}::#{type_name}" }
      candidates << type_name

      candidates.each do |candidate|
        begin
          constant = candidate.constantize
          return constant if candidate == constant.to_s
        rescue NameError => e
          # We don't want to swallow NoMethodError < NameError errors
          raise e unless e.instance_of?(NameError)
        end
      end

      raise NameError, "uninitialized constant #{candidates.first}"
    end

    def self.parse_includes(klass, *tables)
      tables.map do |table|
        case table
        when Hash
          table.map do |k, v|
            parse_includes(klass, *v).map do |sub|
              "#{k}.#{sub}"
            end
          end
        when Array
          table.map do |v|
            parse_includes(klass, *v)
          end
        else
          klass.key_formatter.format(table)
        end
      end.flatten
    end

  end
end
