module JsonApiClient
  module Helpers
    module Callbacks
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :save, :destroy, :create, :update
      end

      module ClassMethods

        [:save, :destroy, :create, :update].each do |operation|
          [:before, :after, :around].each do |type|
            define_method "#{type}_#{operation}" do |*methods, &block|

              if block
                set_callback operation, type, *methods, block
              else
                set_callback operation, type, *methods
              end

            end
          end
        end

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
