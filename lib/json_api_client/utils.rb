module JsonApiClient
  module Utils

    def self.compute_type(klass, type_name)
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

  end
end