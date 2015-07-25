module JsonApiClient
  module Helpers
    module Requestable
      extend ActiveSupport::Concern

      included do
        attr_accessor :last_result_set
        class_attribute :requestor_class, instance_accessor: false
        self.requestor_class = Query::Requestor
      end

      module ClassMethods
        def create(conditions = {})
          new(conditions).tap do |resource|
            resource.save
          end
        end

        def requestor
          @requestor ||= requestor_class.new(self)
        end
      end

      def save
        return false unless valid?

        self.last_result_set = if persisted?
          self.class.requestor.update(self)
        else
          self.class.requestor.create(self)
        end

        # self.errors = last_result_set.errors
        if last_result_set.has_errors?
          last_result_set.errors.each do |error|
            if error.source_parameter
              errors.add(error.source_parameter, error)
            else
              errors.add(:base, error)
            end
          end
          false
        else
          mark_as_persisted!
          if updated = last_result_set.first
            self.attributes = updated.attributes
          end
          true
        end
      end

      def destroy
        self.last_result_set = self.class.requestor.destroy(self)
        if !last_result_set.has_errors?
          self.attributes.clear
          true
        else
          false
        end
      end

    end
  end
end
