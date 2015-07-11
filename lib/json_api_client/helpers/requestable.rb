module JsonApiClient
  module Helpers
    module Requestable
      extend ActiveSupport::Concern

      included do
        attr_accessor :last_result_set, :errors
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
        self.last_result_set = if persisted?
          self.class.requestor.update(self)
        else
          self.class.requestor.create(self)
        end

        self.errors = last_result_set.errors
        if last_result_set.has_errors?
          false
        else
          self.errors.clear if self.errors
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
