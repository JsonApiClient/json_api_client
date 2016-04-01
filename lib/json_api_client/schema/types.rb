module JsonApiClient
  module Schema
    module Types

      class << self
        def all
          @all ||= {}
        end

        def register(klass, type_or_types, options = {})
          Array(type_or_types).each do |type|
            all[type] = klass
          end
        end

        def build(options = {})
          find_type(options[:type]).new(options)
        end

        def find_type(type)
          all.fetch(type) do
            Base
          end
        end
      end

      class Base
        def initialize(*); end
        def cast(value); value; end
        def type; :base; end
      end

      class Association < Base
        attr_accessor :association
        def initialize(association:, type:)
          self.association = association
        end

        def type
          :association
        end

        def cast(value)
          association.association_class.load(value)
        end
      end

      class MultiAssociation < Base
        attr_accessor :association
        def initialize(association:, type:)
          self.association = association
        end

        def type
          :multi_association
        end

        def cast(value)
          return [] unless value
          value = [value] unless value.is_a?(Array)
          value.map{|val| association.association_class.load(val)}
        end
      end

      class Integer < Base
        def cast(value)
          value.to_i
        end

        def type
          [:int, :integer]
        end
      end

      class String < Base
        def cast(value)
          value.to_s
        end

        def type
          :string
        end
      end

      class Float < Base
        def cast(value)
          value.to_f
        end

        def type
          :float
        end
      end

      class Boolean < Base
        def cast(value)
          case value
          when "false", "0", 0, false
            false
          when "true", "1", 1, true
            true
          else
            false
          end
        end

        def type
          :boolean
        end
      end

      class Time < Base
        def cast(value)
          value.is_a?(::Time) || nil ? value : ::Time.parse(value)
        end

        def type
          :time
        end
      end

      register(Association, :association)
      register(Boolean, :boolean)
      register(Float, :float)
      register(Integer, [:integer, :int])
      register(String, :string)
      register(Time, :time)

    end
  end
end
