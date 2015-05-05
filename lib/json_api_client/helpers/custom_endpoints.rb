module JsonApiClient
  module Helpers
    module CustomEndpoints
      extend ActiveSupport::Concern

      module ClassMethods
        def custom_endpoint(name, options = {})
          if :collection == options.delete(:on)
            collection_endpoint(name, options)
          else
            member_endpoint(name, options)
          end
        end

        def collection_endpoint(name, options = {})
          metaclass = class << self
            self
          end
          metaclass.instance_eval do
            define_method(name) do |*params|
              request_params = params.first || {}
              requestor.custom(name, options, request_params)
            end
          end
        end

        def member_endpoint(name, options = {})
          define_method name do |*params|
            request_params = params.first || {}
            request_params[self.class.primary_key] = attributes.fetch(primary_key)
            self.class.requestor.custom(name, options, request_params)
          end
        end
      end
    end
  end
end