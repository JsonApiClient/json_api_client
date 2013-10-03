module JsonApiClient
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(attr_name)
          self.associations.push(HasMany::Association.new(attr_name))
        end
      end

      class Association
        attr_reader :attr_name, :options
        def initialize(attr_name, options = {})
          @attr_name = attr_name
          @options = options
        end

        def association_klass
          @association_klass ||= options.fetch(:class_name) do
            attr_name.to_s.classify
          end.constantize
        end

        def parse(param)
          [param].flatten.map{|data| association_klass.new(data) }
        end
      end
    end
  end
end