module JsonApiClient
  module Helpers
    module CustomHeaders
      extend ActiveSupport::Concern

      module ClassMethods
        def with_headers(headers)
          self.custom_headers = headers
          yield
          self.custom_headers = {}
        end

        def custom_headers
          key = "json_api_client-#{resource_name}"
          Thread.current[key] ||= {}
        end

        def custom_headers=(headers)
          key = "json_api_client-#{resource_name}"
          Thread.current[key] = headers
        end
      end

    end
  end
end