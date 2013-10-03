module JsonApiClient
  module Associations
    module HasOne
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one(attr_name)
          self.associations.push(HasOne::Association.new(attr_name))
        end
        # alias belongs_to has_many
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

        def parse(params)
          association_klass.new(params)
        end        
      end
    end
  end
end