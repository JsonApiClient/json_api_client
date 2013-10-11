module JsonApiClient
  module Helpers
    module Linkable
      extend ActiveSupport::Concern

      included do
        attr_accessor :links

        initializer do |obj, params|
          links = params.delete(:links)
          obj.links = links if links
        end
      end
    end
  end
end