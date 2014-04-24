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
          self.class.send(:define_method, name) do |*params|
            input = {
              name: name,
              params: request_params = params.first || {}
            }.merge(options)
            run_request(Query::Custom.new(self, input))
          end
        end

        def member_endpoint(name, options = {})
          define_method name do |*params|
            request_params = params.first || {}
            request_params[self.class.primary_key] = attributes.fetch(primary_key)
            input = {
              name: name, 
              params: request_params
            }.merge(options)
            run_request(Query::Custom.new(self.class, input))
          end
        end
      end
    end
  end
end