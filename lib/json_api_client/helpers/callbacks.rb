module JsonApiClient
  module Helpers
    module Callbacks
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks
        define_model_callbacks :save, :destroy, :create, :update
      end

      def save
        run_callbacks :save do
          run_callbacks (persisted? ? :update : :create) do
            super
          end
        end
      end

      def destroy
        run_callbacks :destroy do
          super
        end
      end

    end
  end
end
