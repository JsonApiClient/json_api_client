module JsonApiClient
  module Helpers
    module Requestable
      extend ActiveSupport::Concern

      included do
        attr_reader :last_result_set
        class_attribute :requestor_class
        self.requestor_class = Query::Requestor
      end

      module ClassMethods
        def find(conditions)
          requestor.find(conditions)
        end

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
        if persisted?
          self.class.requestor.update(self)
        else
          self.class.requestor.create(self)
        end.tap do |result_set|
          if result_set.has_errors?
            self.errors = result_set.errors
          else
            self.errors.clear if self.errors
            mark_as_persisted!
            if updated = result_set.first
              self.attributes = updated.attributes
            end
          end
        end
      end

      def destroy
        result_set = self.class.requestor.destroy(self)
        if !result_set.has_errors?
          self.attributes.clear
          true
        else
          false
        end
      end

    end
  end
end